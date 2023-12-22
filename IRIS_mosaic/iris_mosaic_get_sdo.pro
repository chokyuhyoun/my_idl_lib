pro IRIS_MOSAIC_GET_SDO, home_dir, t0, t1, $
	remote = remote, gzip = gzip, waves = waves, nrt = nrt

;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine will make a subdirectory 
; structure under <home_dir>/SDO/ with a PointingXXX subdirectory holding 
; a selection of FITS files (one for each AIA wavelength designated below, 
; and one HMI LOS magnetogram)
;
; INPUT:
;	home_dir	-	Full path to the top-level directory for the IRIS Mosaic.
;	
;	t0/t1	-	Time string (in CCSDS format) for the start/stop of the full
;				disk mosaic queue. Defaults to 
;
; KEYWORDS:
;	/remote		-	(SWITCH) set if you don't have local directory access to
;					SDO files
;	/gzip		-	(SWITCH) set if you want to gzip the FITS files after copying
;					them to the target directory
;	waves		-	(INPUT) set to an array of AIA wavelengths to include
;					Defaults to [1600, 304, 193, 171]
;
;-

if N_ELEMENTS(waves) eq 0 then waves = [1600, 304, 193, 171]
nwaves = N_ELEMENTS(waves)

if N_ELEMENTS(nrt) eq 0 then nrt = 0
;;; Mod. 20180302 ASD
; if nrt then aiads = 'aia.lev1_nrt2' else aiads = 'aia.lev1'
aiads = 'aia.lev1'
hmids = 'hmi.M_45s'
if nrt then begin
   aiads = 'aia.lev1_nrt2' 
   hmids = 'hmi.M_45s_nrt' 
endif
;;; Mod. 20180302 ASD
if N_ELEMENTS(remote) eq 0 then remote = 0
f = FILE_SEARCH( CONCAT_DIR(home_dir, 'level2/*.fits'), count = fc)

; Query JSOC for AIA and HMI data
metafile = CONCAT_DIR(home_dir, 'SDO/sdo_meta.genx')
tai0 = ANYTIM2TAI(t0)	;	start of the whole mosaic
tai1 = ANYTIM2TAI(t1)	;	end of the whole mosaic
tai2 = tai0				;	start of this chunk
tai3 = tai2 + 7200d		;	end of this chunk
while tai2 le tai1 do begin		;	Seems to hang less if you break the JSOC query up into 1hr chunks
	SSW_JSOC_TIME2DATA, TAI2UTC(tai2, /ccsds), TAI2UTC(tai3, /ccsds), /jsoc2, $
		ds = aiads, waves = waves, files = 1 - remote, urls = remote, $
		key = 'WAVELNTH,T_OBS,DATAMEAN,EXPTIME,FSN,QUALITY', $
		this_drms_aia, this_files_aia
	SSW_JSOC_TIME2DATA, TAI2UTC(tai2, /ccsds), TAI2UTC(tai3, /ccsds), /jsoc2, $
                ;;; Mod. 20180302 ASD
		;ds = 'hmi.M_45s', files = 1 - remote, urls = remote, $
		ds = hmids, files = 1 - remote, urls = remote, $
                ;;; Mod. 20180302 ASD
		key = 'T_OBS,DATE__OBS,DATAMEAN,CAMERA,QUALITY,CRPIX1,CRPIX2,CROTA2,RSUN_OBS,DSUN_OBS', $
		this_drms_hmi, this_files_hmi
	if N_TAGS(this_drms_aia) gt 0 then begin
		if N_ELEMENTS(drms_aia_all) eq 0 then begin
			drms_aia_all = this_drms_aia
			files_aia_all = this_files_aia
		endif else begin
			drms_aia_all = CONCAT_STRUCT(drms_aia_all, this_drms_aia)
			files_aia_all = [files_aia_all, this_files_aia]
		endelse	
	endif 
	if N_TAGS(this_drms_hmi) gt 0 then begin
		if N_ELEMENTS(drms_hmi_all) eq 0 then begin
			drms_hmi_all = this_drms_hmi
			files_hmi_all = this_files_hmi
		endif else begin
			drms_hmi_all = CONCAT_STRUCT(drms_hmi_all, this_drms_hmi)
			files_hmi_all = [files_hmi_all, this_files_hmi]
		endelse	
	endif
	tai2 = tai3 + 0.0001d	;	Probably don't need to add this buffer...?
	tai3 = tai2 + 7200d
endwhile
SAVEGEN, file = metafile, drms_aia_all, files_aia_all, drms_hmi_all, files_hmi_all, $
	names = ['drms_aia_all', 'files_aia_all', 'drms_hmi_all', 'files_hmi_all']
atai = ANYTIM2TAI(drms_aia_all.t_obs)
htai = ANYTIM2TAI(drms_hmi_all.t_obs)

; Loop through the IRIS pointings in the mosaic
for ii = 0, fc-1 do begin
	PRINT, ii
	tmp_dir = CONCAT_DIR(home_dir, 'SDO/Pointing'+fns('###',ii) )
	SPAWN, 'mkdir ' + tmp_dir, result, errcode

	; Read the lev2 files for this pointing
	l2f = f[ii]
	d = OBJ_NEW('iris_data')
	d->READ, l2f
	index = d->gethdr(/struct)
	solarx=d->getxpos()
	xfac = [MEAN(solarx), MEAN(DERIV(solarx))]
	solary=d->getypos()
	yfac = [MEAN(solary), MEAN(DERIV(solary))]
	tstart = index.date_obs
	tend = index.date_end

	; Now just pick one of the files for each AIA wavelength and save it 
	; locally. Note that the old version seemed to just pick the first file in
	; the time window. Does that make sense? Should we break it down further?
	aind = WHERE(atai ge ANYTIM2TAI(tstart) and atai le ANYTIM2TAI(tend), numaia)
	if numaia gt (nwaves * 2) then begin	;	Rough check for good AIA data
		drms_aia = drms_aia_all[aind]
		files_aia = files_aia_all[aind]
		for jj=0, N_ELEMENTS(waves)-1 do begin
			waveind = WHERE(drms_aia.wavelnth eq waves[jj], numwave)
			if numwave gt 0 then begin
				useind = MEDIAN(waveind)
				ofile = CONCAT_DIR(tmp_dir, aiads + '.' + STRCOMPRESS(waves[jj],/rem) + $
					'A_' + TIME2FILE(drms_aia[useind].t_obs, /sec) + '.fits' )
				if not (FILE_EXIST(ofile) or FILE_EXIST(ofile + '.gz')) then begin
					if remote then begin
						SOCK_COPY, files_aia[useind], FILE_BASENAME(ofile), out_dir = tmp_dir
					endif else begin
						SPAWN, 'cp ' + files_aia[useind] + ' ' + ofile
					endelse
				endif
			endif else begin
				; Copy this wavelength file from the previous pointing
				backdir = CONCAT_DIR(tmp_dir, '../Pointing' + STRTRIM(ii-1, 2))
				backfile = FILE_SEARCH(CONCAT_DIR(backdir, '*' + STRTRIM(waves[jj], 2) + '*'))
				SPAWN, 'cp ' + backfile + ' ' + tmp_dir
			endelse
		endfor
	endif
	
	; Now pick one of the HMI magnetograms. Note that the old version seemed
	; to be averaging the magnetograms, and zeroing it outside of 0.999 Rsun.
	; Is that necessary?
	hind = WHERE(htai ge ANYTIM2TAI(tstart) and htai le ANYTIM2TAI(tend), numhmi)
	if numhmi gt 0 then begin		;	Rough check for good HMI data
		drms_hmi = drms_hmi_all[hind]
		files_hmi = files_hmi_all[hind]
		if not FILE_EXIST( CONCAT_DIR(tmp_dir, '/hmi.*') ) then begin
			useind = N_ELEMENTS(files_hmi)/2
			htimetag = TIME2FILE(ANYTIM2UTC(/ccsds, drms_hmi[useind].t_obs), /sec)
                        ;;; Mod. 20180302 ASD
			; ofile = CONCAT_DIR(tmp_dir, 'hmi.M_45s.' + htimetag + '.fits')
			ofile = CONCAT_DIR(tmp_dir, hmids+'.' + htimetag + '.fits')
                        ;;; Mod. 20180302 ASD
			if not (FILE_EXIST(ofile) or FILE_EXIST(ofile + '.gz')) then begin
				if remote then begin
					SOCK_COPY, files_hmi[useind], FILE_BASENAME(ofile), out_dir = tmp_dir
				endif else begin
					SPAWN, 'cp ' + files_hmi[useind] + ' ' + ofile
					SAVEGEN, file = CONCAT_DIR(tmp_dir, 'hmi.hdr.' + htimetag + '.genx'), $
						drms_hmi[useind]
				endelse
			endif		
		endif
	endif
	
	if KEYWORD_SET(gzip) then SPAWN, 'gzip -f ' + CONCAT_DIR(tmp_dir, '*.fits')

endfor

end
