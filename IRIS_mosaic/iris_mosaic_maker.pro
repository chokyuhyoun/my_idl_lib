pro IRIS_MOSAIC_MAKER, t0, t1, home, $
	silent = silent, pstop = pstop, debug = debug, remote = remote, $
	nrt = nrt, force = force, clean = clean, superkludge = superkludge, $
	nodoppler = nodoppler, _extra = extra, no_web=no_web, nohtml = nohtml, $
        kludge_fuv = kludge_fuv

;+
;
; Top-level routine for making IRIS full-disk mosaic FITS files. 
;
; INPUTS:
;	t0/t1	-	Time string (in CCSDS format) for the start/stop of the full
;				disk mosaic queue. Defaults to 
;						t0 = '2014-10-14 01:00:00'
;						t1 = '2014-10-14 15:38:00'
;
;	home	-	String giving full path for top level directory to hold the results
;				The final directory level name must be in YYYYMMDD format
;				Defaults to CONCAT_DIR('/irisa/data/MosaicTest/', TIME2FILE(t0, /date))
;
; KEYWORDS:
;	/silent	-	(SWITCH) if set, then don't make any plots here or in the subroutines
;				Runs faster, and better as a batch job. Still prints stuff to the
;				terminal/log file
;	/debug	-	(SWITCH) if set, then some timing information is printed along
;				the way
;	/remote	-	(SWITCH) set if you don't have direct access to the IRIS and SDO
;				level 1 data; in that case, it will be exported from the JSOC
;				(MUCH slower and consumes a lot of disk space; not tested very well,
;				either)
;	/pstop	-	(SWITCH) brake inside the routine for debugging
;	/force	-	(SWITCH) set to 0 if you want to re-use already-made lev2 files; 
;				by default, force=1 is passed to iris_mosaic_makelevel2
;	/clean	-	(SWITCH) set to 1 if you want to try to minimize the disk space
;				used by the various mosaic data files
;	/superkludge -	(SWITCH) set to 1 if you want to fix the pedestal offset
;					AFTER the lev2 data has been produced (you can also set the
;					/kludge_fuv keyword which gets passed to iris_prep if you 
;					want to fix it in lev2)
;	/nrt	-	(SWITCH) set if you want to use NRT data
;	/nodoppler -(SWITCH) set to 1 if you want the HTML file not to include the
;				dopplergrams (passed to IRIS_MOSAIC_WEB)
;	_extra	-	Passed to IRIS_MOSAIC_MAKELEVEL2
;
;-

tt0 = SYSTIME(/sec)

if N_ELEMENTS(nrt) eq 0 then nrt = 0
if N_ELEMENTS(debug) eq 0 then debug = 0
if N_ELEMENTS(remote) eq 0 then remote = 0
if N_ELEMENTS(clean) eq 0 then clean = 0
if N_ELEMENTS(force) eq 0 then force = 1
if N_ELEMENTS(silent) eq 0 then silent = 0
if N_ELEMENTS(nodoppler) eq 0 then nodoppler = 1
if N_ELEMENTS(t0) eq 0 then t0 = '2014-10-14 01:00:00'
if N_ELEMENTS(t1) eq 0 then t1 = '2014-10-14 15:38:00'
if N_ELEMENTS(home) eq 0 then home = CONCAT_DIR('/irisa/data/MosaicTest/', TIME2FILE(t0, /date))
datestr = FILE_BASENAME(home)

; Generate a directory tree
if not FILE_EXIST(home) then SPAWN, 'mkdir ' + home, result, errcode
subdirs = ['figs', 'pointings', 'level2', 'slices', 'SDO', 'jpgs']
for ii = 0, N_ELEMENTS(subdirs) - 1 do begin
	subdir = CONCAT_DIR(home, subdirs[ii])
	if not FILE_EXIST(subdir) then SPAWN, 'mkdir ' + subdir, result, errcode
endfor

; Look up the level 1 files, and sort them into subdirectories
; for each pointing. Touch a 0 byte file called l1.done when
; this is finished to indicate that it doesn't need to be redone
; if you re-run this routine
l1_done_file = CONCAT_DIR(home, 'l1.done')
if FILE_EXIST(l1_done_file) then begin
	RESTGEN, file = CONCAT_DIR(home, 'lev1_drms.genx'), drms, files
	tt2 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC TIMING Read L1 files: ', tt2 - tt0, form = '(a50,f10.1)'
endif else begin
	IRIS_MOSAIC_GRAB_L1FILES, t0, t1, home_dir = home, /verbose, nrt = nrt, remote = remote, /same
	RESTGEN, file = CONCAT_DIR(home, 'lev1_drms.genx'), drms, files
	tt1 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC TIMING Grab L1 files: ', tt1 - tt0, form = '(a50,f10.1)'
	IRIS_MOSAIC_IDENTIFY_POINTINGS, home_dir = home, /verbose, remote = remote
	tt2 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC TIMING Identify pointings: ', tt2 - tt1, form = '(a50,f10.1)'
	SPAWN, 'touch ' + l1_done_file
endelse

; Make level 2 files for each pointing. Use a 0B control file called l2.done
; to decide if this should be redone
l2_done_file = CONCAT_DIR(home, 'l2.done')
if FILE_EXIST(l2_done_file) eq 0 then begin
	if keyword_set(kludge_fuv) eq 1 then print, 'kludge_fuv = ', kludge_fuv
	IRIS_MOSAIC_MAKELEVEL2, home_dir = home, /verbose, /skipper, remote = remote, $
                                force = force,kludge_fuv=kludge_fuv, _extra = extra
                                ;Nov 25 added kludge_fuv
        ;Mar23 2016 kludge_fuv=0
	tt3 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC TIMING Make level 2 data: ', tt3 - tt2, form = '(a50,f10.1)'
	SPAWN, 'touch ' + l2_done_file
endif
tt3 = SYSTIME(/sec)

; Fit wavelength corrections for each image in the mosaic, and save
; them in a .genx file in the home directory. This part is hard to get 
; exactly right...
wc_file = CONCAT_DIR(home, datestr + '_IRIS_Mosaic_Corrections.genx')
wc_done_file = CONCAT_DIR(home, 'corrections.done')
if (FILE_EXIST(wc_done_file) eq 0) then begin
	IRIS_MOSAIC_EXTRACT_WAVECORR, home, silent = silent
	SPAWN, 'touch ' + wc_done_file
endif
tt4 = SYSTIME(/sec)
if debug then PRINT, 'IRIS_MOSAIC TIMING Fitting wavelengths: ', tt4 - tt3, form = '(a50,f10.1)'

; Figure out which spectral windows were used based on the OBS ID 
; Not sure how robust this is...
windaes = ['MgIIh','MgIIk','Si1393','Si1403','C1334', 'C1335']	;	 All
;obsids = drms.isqoltid
;linelist_digit = (obsids[0] / 10000000ll) mod 10
;case linelist_digit of 
;	0	:	windaes = windaes[[0,1,2,3,4,5]]	;	large
;	2	:	windaes = windaes[[0,1,2,3,4,5]]	;	medium
;	4	:	windaes = windaes[[1,3,4,5]]		;	small
;	6	:	windaes = windaes[[0,1,3,4,5]]		;	flare 1
;	8	:	windaes = windaes[[0,1,2,3,4,5]]	;	full
;	else : 	windaes = windaes[[0,1,2,3,4,5]]	;	??
;endcase
numwin = N_ELEMENTS(windaes)
tt5 = DBLARR(numwin)
tt6 = DBLARR(numwin)
tt7 = DBLARR(numwin)
tt8 = DBLARR(numwin)
if debug then PRINT, 'IRIS_MOSAIC windaes = ', windaes

; Loop through the wavelength windows surrounding all the strong lines 
; taken in the mosaic and construct FITS files with the [X,Y,lambda] array
for jj=0, numwin-1 do begin
	slice_file = CONCAT_DIR(home, datestr + '_IRIS_Mosaic_Slices_'+windaes[jj]+'.genx')
	mos_file = CONCAT_DIR(home, 'IRISMosaic_' + datestr + '_' + windaes[jj] + '.genx')
	mos_fits = CONCAT_DIR(home, 'IRISMosaic_' + datestr + '_' + windaes[jj] + '.fits')
	line_done_file = CONCAT_DIR(home, windaes[jj] + '.done')
	if FILE_EXIST(line_done_file) eq 0 then begin
		tt5[jj] = SYSTIME(/sec)
		IRIS_MOSAIC_EXTRACT_WINDOWS, home, windaes[jj], silent = silent
		tt6[jj] = SYSTIME(/sec)
		if debug then PRINT, 'IRIS_MOSAIC TIMING Extracting window... ', jj, tt6[jj] - tt5[jj], form = '(a50,i5,f10.1)'
                IRIS_MOSAIC_REPOSITION, home, windaes[jj], silent = silent, /force
                                ;added superkludge nov23,
                                ;mar 23 2016 removed /super_kludge
		tt7[jj] = SYSTIME(/sec)
		if debug then PRINT, 'IRIS_MOSAIC TIMING Putting window in frame... ', jj, tt7[jj] - tt6[jj], form = '(a50,i5,f10.1)'
		IRIS_MOSAIC2FITS, mos_file
		tt8[jj] = SYSTIME(/sec)
		if debug then PRINT, 'IRIS_MOSAIC TIMING Making FITS file for window ', jj, tt8[jj] - tt7[jj], form = '(a50,i5,f10.1)'
		SPAWN, 'touch ' + line_done_file
	endif else begin
		if debug then PRINT, 'IRIS_MOSAIC TIMING Already done with window ', jj, form = '(a50,i5)'
	endelse
endfor
tt9 = SYSTIME(/sec)

; Now make SDO FrankenMaps that correspond to the IRIS Mosaics, where each 
; pixel value is picked from the image at the time when IRIS was rastering in
; that part of the disk
sdo_file = CONCAT_DIR(home, datestr + '_IRIS_FrankenMaps_SDO.genx')
sdo_done_file = CONCAT_DIR(home, 'sdo.done')
if (FILE_EXIST(sdo_done_file) eq 0) and (nrt eq 0) then begin
	waves = [1700, 1600, 304, 193, 171]
	IRIS_MOSAIC_GET_SDO, home, t0, t1, waves = waves, nrt = nrt
	tt10 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC TIMING Getting SDO data: ', tt10 - tt9, form = '(a50,f10.1)'
	IRIS_MOSAIC_CLIP_SDO, home, waves = waves, silent = silent
	tt11 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC TIMING Clipping SDO data: ', tt11 - tt10, form = '(a50,f10.1)'
	IRIS_MOSAIC_REBUILD_FRANK, home, waves = waves, silent = silent
	SPAWN, 'touch ' + sdo_done_file
endif else begin
	if debug then PRINT, 'IRIS_MOSAIC TIMING Already done with SDO ', form = '(a50)'
endelse

if keyword_set(no_web) eq 0 then begin
   ; Now make SDO FrankenMaps that correspond to the IRIS Mosaics, where each 
   ; pixel value is picked from the image at the time when IRIS was rastering in
   ; that part of the disk
   web_done_file = CONCAT_DIR(home, 'web.done')
   if FILE_EXIST(web_done_file) eq 0 then begin
   	tt12 = SYSTIME(/sec)
	IRIS_MOSAIC_WEB, home, nosdofits = nrt, nodoppler = nodoppler, nohtml = nothml 
	tt13 = SYSTIME(/sec)
	if debug then PRINT, 'IRIS_MOSAIC_TIMING Webifying mosaic: ', tt13 - tt12, form = '(a50,f10.1)'
;	SPAWN, 'mv ' + CONCAT_DIR(home, 'mosaic_test.html') + ' ' + CONCAT_DIR(html_dir, 'mosaic.html')
   endif else begin
	if debug then PRINT, 'IRIS_MOSAIC TIMING Already done with webification ', form = '(a50)'
   endelse
endif 

if KEYWORD_SET(clean) then begin
	SPAWN, 'gzip -f '+ mos_fits
endif

tt14 = SYSTIME(/sec)
if debug then PRINT, 'IRIS_MOSAIC TIMING Total elapsed time: ', tt13 - tt0, form = '(a50,f10.1)'

if KEYWORD_SET(pstop) then STOP

end
