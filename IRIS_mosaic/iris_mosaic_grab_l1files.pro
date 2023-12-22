pro IRIS_MOSAIC_GRAB_L1FILES, t0, t1, $
	home_dir = home_dir, verbose = verbose, remote = remote, nrt = nrt, $
	same_obsid = same_obsid, obsid_to_use = obsid_to_use

;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine reads in the metadata for all 
; the lev1 files taken as part of the mosaic. 
;
;		This routine will make a file called 
;			<home_dir>/lev1_drms.genx
;	which holds the headers and file names for all the lev1 files.
;
; INPUT:
;	t0, t1	-	Start and end times for the mosaic observation
;
; KEYWORDS:
;	home_dir	-	(INPUT) full path to the top-level directory for this mosaic.
;
;	/remote		-	(SWITCH) set if working remotely, in which case the routine
;					will request all the lev1 files from the JSOC and store them
;					at <home_dir>/level1/ . By default,	it assumes that it already
;					has local access to all the lev1 files, and just stores the
;					headers and filenames/paths
;	/same_obsid	-	(SWITCH) set to force the routine to only keep images taken
;					with the same OBS ID (picks the most popular OBS ID during
;					the time window). Helps avoid priming frames or an overly wide
;					time window.
;	obsid_to_use-	(OUTPUT) set to the most common OBS ID in the interval
;					(whether or not the /same keyword is set to exclude others)
;
;-

if N_ELEMENTS(home_dir) eq 0 then home_dir = './'
remote = KEYWORD_SET(remote)
verbose = KEYWORD_SET(verbose)
nrt = KEYWORD_SET(nrt)

;edited
fl = IRIS_TIME2FILES(t0, t1, drms, /jsoc2, key='IISSPZTB,XCEN,YCEN,ISQFLTDX,ISQFLTNX,IIFLNRPT,ISQOLTID,IWM1CTGT,IWM2CTGT,ISQOLTDX,ISQOLTNX', $
	url = remote, nrt = nrt)
; Check OBS IDs
;stop
obsids = drms.isqoltid
sobsids = obsids[SORT(obsids)]
if (MAX(obsids) ne MIN(obsids)) then begin
	PRINT, 'IRIS_MOSAIC_GRAB_L1FILES: OBS ID mismatch...', $
	MAX(obsids), MIN(obsids), form = '(a50, 2i12)'
	uniq_obsids = sobsids[SSW_UNIQ(sobsids)]
	numuniq = N_ELEMENTS(uniq_obsids)
	obscount = LONARR(numuniq)
	for i = 0, numuniq - 1 do $
		obscount[i] = N_ELEMENTS(WHERE(obsids eq uniq_obsids[i]))
	obsid_to_use = (uniq_obsids[WHERE(obscount eq MAX(obscount))])[0]
	if KEYWORD_SET(same_obsid) then begin
		keeper = WHERE(obsids eq obsid_to_use)
		fl = fl[keeper]
		drms = drms[keeper]
		PRINT, 'IRIS_MOSAIC_GRAB_L1FILES: Filtered to unique OBS ID...', $
			obsid_to_use, form = '(a50, i12)'
	endif
endif

nfiles = N_ELEMENTS(fl)
PRINT, 'IRIS_MOSAIC_GRAB_L1FILES: There are '+STRCOMPRESS(nfiles)+' files in the mosaic.'

if remote then begin
	PRINT, 'IRIS_MOSAIC_GRAB_L1FILES: Fetching...'
	SPAWN, 'mkdir ' + CONCAT_DIR(home_dir, 'level1/')
	SPAWN, 'mkdir ' + CONCAT_DIR(home_dir, 'level1/sji/')
	SPAWN, 'mkdir ' + CONCAT_DIR(home_dir, 'level1/fuv/')
	SPAWN, 'mkdir ' + CONCAT_DIR(home_dir, 'level1/nuv/')
	for ii = 0l, nfiles-1 do begin
	   url = fl[ii]
	   filebase = FILE_BASENAME(url)
	   odir = STRMID(filebase, 22, 3)
	   ofile = CONCAT_DIR(home_dir, 'level1/'+odir+'/'+filebase)
	   if verbose then PRINT, ii, nfiles-1, ofile, form = '(2i10,a50)'
	   if FILE_EXIST(ofile) or FILE_EXIST(ofile+'.gz') then goto, skip
	   SOCK_GET, url, filebase, out_dir = CONCAT_DIR(home, 'level1/'+odir) 
	   skip:
	endfor
	files = FILE_SEARCH(CONCAT_DIR(home_dir, 'level1/*/*'))
endif else begin
	files = fl
endelse

; Kludge to handle mosaic on 2015-04-01 where telemetry was dropped near
; the beginning of the mosaic, resulting in an orphan file that screws 
; everything up.
if (drms[0].t_obs eq '2015-04-01T10:24:53.06Z') then begin
	drms = drms[1:*]
	files = files[1:*]
endif

SAVEGEN, file = CONCAT_DIR(home_dir, 'lev1_drms.genx'), drms, files, names = ['drms', 'files']

end
