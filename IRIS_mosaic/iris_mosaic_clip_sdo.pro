pro IRIS_MOSAIC_CLIP_SDO, home_dir, $
	silent = silent, gzip = gzip, waves = waves, pstop = pstop, force = force

;+
;
; INPUT:
;	home_dir	-	Full path to the top-level directory for the IRIS Mosaic.
;	
;		This routine will make a series of genx files under 
;		<home_dir>/SDO/maps/PointingXXX_maps.genx
;		holding the sub-framed SDO data corresponding to that mosaic pointing
;
; KEYWORDS:
;	waves		-	(INPUT) set to an array of AIA wavelengths to include
;					Defaults to [1600, 304, 193, 171]
;	/silent		-	(SWITCH) set to avoid plotting sub-images along the way
;	/gzip		-	(SWITCH) set if you want to gzip the FITS files after 
;					reading them
;	/force		-	(SWITCH, defaults to 1!) Set to 0 if you want to avoid
;					remaking maps when they are already found
;					CURRENTLY NOT IMPLEMENTED; IT'S ALWAYS 1
;
;-
 
if N_ELEMENTS(force) eq 0 then force = 1
if N_ELEMENTS(waves) eq 0 then waves = [1600, 304, 193, 171]
nwaves = N_ELEMENTS(waves)

f = FILE_SEARCH( CONCAT_DIR(home_dir, 'level2/*.fits'), count = fc)

SPAWN, 'mkdir ' + CONCAT_DIR(home_dir, 'SDO/maps')

if not KEYWORD_SET(silent) then begin
	WINDOW, 0, xs = 512, ys = 512	
	WINDOW, 1, xs = 512, ys = 512
endif

; Loop through pointings and save a map structure 
; holding all the SDO data for that pointing
for ii =0, fc-1 do begin

	PRINT, ii
	tmp_dir = CONCAT_DIR(home_dir, 'SDO/Pointing'+fns('###',ii))
	ofile = CONCAT_DIR(home_dir, 'SDO/maps/Pointing'+fns('###',ii)+'_maps.genx')
	; if FILE_EXIST(ofile) and force eq 0 then goto, skip

	l2f = f[ii]
	d=OBJ_NEW('iris_data')
	d->READ, l2f

	index = d->GETHDR(/struct)
	solarx = d->GETXPOS()
	xfac = [MEAN(solarx), MEAN(DERIV(solarx))]
	solary = d->GETYPOS()
	yfac = [MEAN(solary), MEAN(DERIV(solary))]
	tstart = index.date_obs
	tend = index.date_end
	mapstr = {solarx : solarx, solary : solary, tstart : tstart, tend : tend}

	zipfiles = FILE_SEARCH( CONCAT_DIR(tmp_dir, '*gz*'), count = gc)
	if gc gt 0 then for jj = 0, gc-1 do SPAWN, 'gunzip -f ' + zipfiles[jj]
	all_files = FILE_SEARCH( CONCAT_DIR(tmp_dir, '*fits*'), count = ffc)
	if fc lt nwaves + 1 then begin
		; If it doesn't have enough FITS files, just copy in the stuff from the
		; last pointing. Pretty rough, but should keep things moving
		PRINT, 'IRIS_MOSAIC_CLIP_SDO: Missing some SDO data...?'
		prevpath = CONCAT_DIR(home_dir, 'SDO/Pointing'+fns('###',ii-1))
		SPAWN, 'cp ' + CONCAT_DIR(prevpath, '*fits') + ' ' + tmp_dir
		all_files = FILE_SEARCH( CONCAT_DIR(tmp_dir, '*fits*'), count = ffc)
	endif
	all_bases = FILE_BASENAME(all_files)
	
	if KEYWORD_SET(pstop) then STOP
	
	; Loop through the SDO channels
	for jj = 0, ffc-1 do begin
		if STRMID(all_bases[jj], 0, 3) eq 'hmi' then begin
			READ_SDO, all_files[jj], trash_hdr, idata, /use_shared_lib
			hdrfile = FILE_SEARCH( CONCAT_DIR(tmp_dir, 'hmi*genx') )
			RESTGEN, file = hdrfile, iindex
			iindex = CREATE_STRUCT(iindex, 'INSTRUME', 'HMI_FRONT2', $
				'CRVAL1', 0., 'CRVAL2', 0., $
				'CDELT1', 0.504321, 'CDELT2', 0.504321)
			AIA_PREP, iindex, idata, index, data
			tagname = 'hmi'
			windex = 0
		endif else begin
			AIA_PREP, all_files[jj], [0], index, data, /normalize
			tagname = 'aia_' + STRING(index.wavelnth, form = '(i04)')
			windex = 1
		endelse
		INDEX2MAP, index, FLOAT(data), thismap
		SUB_MAP, thismap, thissub, xrange = minmax(solarx), yrange = minmax(solary)
		if not KEYWORD_SET(silent) then begin
			WSET, windex
			if tagname eq 'hmi' then PLOT_MAP, thissub, dmin = -20, dmax = 20 $
				else PLOT_MAP, thissub, /log
		endif
		maptags = TAG_NAMES(mapstr)						;	Make sure you haven't already
		tagpos = WHERE(STRUPCASE(tagname) eq maptags, hastag)	;	added this channel
		if hastag eq 0 then mapstr = CREATE_STRUCT(mapstr, tagname, thissub)
		if KEYWORD_SET(gzip) then SPAWN, 'gzip -f ' + all_files[jj]
	endfor
	SAVEGEN, file = ofile, str = mapstr
	skip:
	
endfor

end
