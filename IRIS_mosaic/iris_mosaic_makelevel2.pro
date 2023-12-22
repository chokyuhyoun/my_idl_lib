pro IRIS_MOSAIC_MAKELEVEL2, $
	home_dir = home_dir, verbose = verbose, override = override, $
	revpoint = revpoint, skipper = skipper, remote = remote, force = force, $
	_extra = extra
	
;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine makes level2 fits files for 
; each pointing. This is the most time-consuming step in the mosaic analysis
;
; KEYWORDS:
;	home_dir	-	(INPUT) string giving full path to top level for this OBS
;	/verbose	-	(SWITCH) set to print out a bunch of stuff
;	/remote		-	(SWITCH) set if you are running remotely and thus had to
;					copy all the l1 files to a local area
;	/revpoint	-	(SWITCH) set to process the pointings in reverse order
;	/skipper	-	(SWITCH) set if you don't want to halt when it fails to 
;					make a lev2 raster file (by default, it stops in that case)
;	/force		-	(SWITCH) if set, then remake the lev2 even if it has
;					already been made
;	override	-	(INPUT) integer specifying a single pointing index to process
;					(by default, it runs through all the pointings in home_dir)
;
;-
 
if N_ELEMENTS(home_dir) eq 0 then home_dir = './'
verbose = KEYWORD_SET(verbose)
remote = KEYWORD_SET(remote)
skipper = KEYWORD_SET(skipper)

;edited
;RESTGEN, file = CONCAT_DIR(home_dir, 'pointkey.genx'), pointkey

points = FILE_SEARCH(CONCAT_DIR(home_dir, 'pointings/*'), count = npoints)
if KEYWORD_SET(revpoint) then points = REVERSE(points)
if KEYWORD_SET(override) then begin
	ostring = STRING(override[0], form = '(i03)')
   PRINT, 'IRIS_MOSAIC_MAKELEVEL2: only Processing Pointing ' + ostring
   points = FILE_SEARCH(CONCAT_DIR(home_dir, 'pointings/' + ostring), count = npoints)
endif

ofolder = CONCAT_DIR(home_dir, 'level2')

; Loop through the pointings
for ii=0, npoints-1 do begin

	ipoint = FIX(FILE_BASENAME(points[ii]))
	dir = points[ii]
        resultfile = CONCAT_DIR(dir, 'level2/*raster.log')
        rfitsfile=CONCAT_DIR(dir, 'level2/*raster*.fits')
	; Skip it if you're already done
    if (FILE_EXIST(resultfile) eq 1) and (~force) then begin
    	PRINT, 'IRIS_MOSAIC_MAKELEVEL2: Already done with ' + resultfile
    endif else begin
    	; Look up the list of lev1 files associated with this pointing
		if verbose then PRINT, 'IRIS_MOSAIC_MAKELEVEL2: Processing ' + dir
		SPAWN, 'mkdir ' + CONCAT_DIR(dir, 'level2/')
		pfiles = FILE_SEARCH(CONCAT_DIR(dir, '*_lev1_point.genx'))
		for jj = 0, N_ELEMENTS(pfiles)-1 do begin
			RESTGEN, file = pfiles[jj], thispointfiles, thisbanddrms
			if jj eq 0 then l15files = thispointfiles else l15files = [l15files, thispointfiles]
		endfor
		nfits = N_ELEMENTS(l15files)
	
		; If running remotely, unzip l1 files and check to see what you've got
		if remote then begin
			f = FILE_SEARCH(CONCAT_DIR(dir, '*.gz'), count = gc)
			if gc gt 0 then for jj =0,gc-1 do spawn, 'gunzip -f '+f[jj]
			l15files = file_search(CONCAT_DIR(dir, '*.fits'), count = nfits)
		endif
	
		; Make the lev2 data
		IRIS_LEVEL1TO2, l15files, CONCAT_DIR(dir, 'level2/'), /spectral, $
			/flat, _extra = extra

		;where is iris_prep
		;which,'iris_prep'
		;print, '================================================================================'
		;print, 'The PATH is:'
		;print, !PATH
		;print, '================================================================================'
                ;stop

		; If running remotely, rezip the l1 files
		if remote then begin
			for jj=0,nfits-1 do SPAWN, 'gzip -f '+l15files[jj]
			f = FILE_SEARCH(CONCAT_DIR(dir, '/*.fits'), count = gc)
			for jj=0,gc-1 do SPAWN, 'gzip -f '+f[jj]
		endif
	
		; Check to see if you made a raster file
		ffs = FILE_SEARCH( rfitsfile )
		if ffs[0] eq '' then begin
			if skipper eq 0 then STOP
		endif
		; Copy lev2 files from home/pointings/###/level2 to home/lev2
		SPAWN, 'cp ' + ffs[0] + ' ' + ofolder, result, errcode
	endelse

endfor

end
