pro IRIS_MOSAIC_REPOSITION, dir, winname, $
	force = force, silent = silent, watch = watch, superkludge = superkludge

;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine puts the clippings from each IRIS
; raster into the full-disk mosaic frame
;
; INPUT:
;	dir		-	Full path to the top-level directory for the IRIS Mosaic.
;	winname	-	String describing the spectral window for which to run
;
;		This routine will make a file called 
;			<dir>/IRISMosaic_YYYYMMDD_<winname>.genx
;
; KEYWORDS:
;	/force	-	(SWITCH) If set, then the mosaic file is remade even if an old 
;				one is found. By default, this routine returns if the output
;				file already exists
;	/silent	-	(SWITCH) If set, then it does not plot anything; by default, it
;				produces 3 plot windows showing coverage, intensity and doppler
;				shift
;	/watch	-	(SWITCH) If set, then the above plots are displayed step by
;				step as the mosaic is built up. Slow!
;	/superkludge -	(SWITCH) applies the FUV dark frame kludge (to remove 
;					pedestal offsets), assuming that it is a) desired, and b) not
;					applied to the lev2 data directly. Should be no harm in 
;					setting this keyword even if it was already applied...?
;	
;
;- 

datestr = FILE_BASENAME(dir)
slicefile = CONCAT_DIR(dir, 'slices/' + datestr + '_IRIS_Mosaic_Slices_' + winname + '.genx')
ofile = CONCAT_DIR(dir, 'IRISMosaic_' + datestr + '_' + winname + '.genx')

RESTGEN, file = slicefile, output, coord, ref_wave, ref_prof, zero_position, $
	red_pos, blue_pos, lambda_ref, rwp, bwp, cp, fitpos, toutput

if FILE_EXIST(ofile) and not KEYWORD_SET(force) then begin
	PRINT, 'IRIS_MOSAIC_REPOSITION: Found ', ofile
	RETURN
endif

dy = MEAN(DERIV(coord[1,0,*]))
dx = MEAN(DERIV(coord[0,64:127,0]))
aa = SIZE(output)
nspec = aa[1]
nnx = aa[2]
nny = aa[3]
ny = 2000./dy
nx = 2000./dx

solarx = (FINDGEN(nx)-nx/2.)*dx
solary = (FINDGEN(ny)-ny/2.)*dy
suncube = FLTARR(FIX(nx), FIX(ny), nspec)
mask = FLTARR(FIX(nx), FIX(ny))		;	Number of images covering each pixel
tmask = DBLARR(FIX(nx), FIX(ny))	;	Time since t0 of image covering each pixel
ymask = INTARR(FIX(nx), FIX(ny)) - 1;	Y coordinate in lev2 frame of each mosaic pixel

; Set up window to display mosaic as it is built up
if not KEYWORD_SET(silent) then begin
	TVLCT, rr, gg, bb, /get
	LOADCT, 3, /silent
	WINDOW, 0, xs = 1024, ys = 1024
	WINDOW, 1, xs = 1024, ys = 1024
	WINDOW, 2, xs = 1024, ys = 1024
endif

; Loop through slit positions (raster steps * number of pointings)
for ii =0, nnx-1 do begin
   odata = REFORM(output[*,ii,*])
;   print,'pointing ',ii,' ',nnx
	if KEYWORD_SET(superkludge) then begin
		case winname of
			'Si1403'	:	ymid = 269
			'Si1393'	:	ymid = 272
			'C1334'		:	ymid = 285
			'C1335'		:	ymid = 285
			else		:	ymid = 0
		endcase
		if ymid gt 0 then begin
			dsize = SIZE(odata)
			case dsize[2] of
				274	:	bbb = 2
				else:	bbb = 1	;	Normally 548
			endcase
			ymid = ymid / bbb
			subimg1 = odata[2:5,50/bbb:250/bbb]
			lows = WHERE(subimg1 lt MEDIAN(subimg1), numlow)
			if numlow gt 2 then begin
				submed1 = MEDIAN(subimg1[lows]) - 0.5
				odata[*,0:ymid-1] = odata[*,0:ymid-1] - submed1
			endif
			subimg2 = odata[2:5,300/bbb:500/bbb]
			lows = WHERE(subimg2 lt MEDIAN(subimg2), numlow)
			if numlow gt 2 then begin
				submed2 = MEDIAN(subimg2[lows]) - 0.5
				odata[*,ymid:*] = odata[*,ymid:*] - submed2
			endif
		endif
	endif
	; Loop through spatial pixel along slit
	for jj =0, nny-1 do begin
		preprofile = REFORM(output[*,ii,jj])
		profile = REFORM(odata[*,jj])
		if TOTAL(preprofile gt 0) le 1 then begin
			;PRINT, 'IRIS_MOSAIC_REPOSITION: Not enough good data...', ii, jj, form = '(a60,2i10)
		endif else begin
			; Decide which pixel in the output array to put this spectrum in
			ddx = (coord[0,ii,jj] - solarx)^2
			ddy = (coord[1,ii,jj] - solary)^2
			min_x = MIN(ddx, mindex_x)
			min_y = MIN(ddy, mindex_y)
			; Increment the mask counter and put the spectrum in place
			mask[mindex_x, mindex_y] = mask[mindex_x, mindex_y] + 1
			suncube[mindex_x, mindex_y,*] = profile
			tmask[mindex_x, mindex_y] = toutput[ii]
			ymask[mindex_x, mindex_y] = jj
		endelse
	endfor

	; Display the raster as it is built up
	if (not KEYWORD_SET(silent)) and (KEYWORD_SET(watch) or (ii eq nnx-1)) then begin
;           stop
           WSET, 0              ;	Mask of observed pixels
		PIH, mask, origin = [MIN(solarx), MIN(solary)], scale = [dx, dy], min = 0, max = 3
		EMPTY
                IRIS_MOSAIC_DOPPLER, r, g, b
                print,'madeithere0'
		TVLCT, r, g, b
		WSET, 1		;	Doppler shift
		PIH, (suncube[*, *, rwp] - suncube[*, *, bwp]), min = -50, max = 50, $
			origin = [min(solarx), min(solary)], scale = [dx, dy], bottom = 1, top = 254
		EMPTY
		
		WSET, 2		;	Intensity at line center
		LOADCT, 3, /silent
		PIH, ALOG10(suncube[*,*,cp]), origin = [MIN(solarx), MIN(solary)], $
			scale = [dx, dy], min = 1, max = 2.5
		EMPTY
	endif

endfor
print,'made it here2'
;stop
SAVEGEN, suncube, solarx, solary, lambda_ref, ref_wave, ref_prof, mask, tmask, ymask, $
	names = ['suncube', 'solarx', 'solary', 'lambda_ref', 'ref_wave', 'ref_prof', $
	'mask', 'tmask', 'ymask'], file = ofile

; First grab the plot windows as PNGs, then tune through the mosaic in wavelength space
if not KEYWORD_SET(silent) then begin
	WSET, 0
	maskimage = TVRD(/true)
	WRITE_PNG, CONCAT_DIR(dir, 'figs/IRISMosaic_' + winname + '_mask.png'), maskimage
	WSET, 1
	dopplerimage = TVRD(/true)
	WRITE_PNG, CONCAT_DIR(dir, 'figs/IRISMosaic_' + winname + '_doppler.png'), dopplerimage
	WSET, 2
	lineimage = TVRD(/true)
	WRITE_PNG, CONCAT_DIR(dir, 'figs/IRISMosaic_' + winname + '_intensity.png'), lineimage

	for ii=0,nspec-1 do PIH, ALOG10(suncube[*,*,ii]), origin = [MIN(solarx), MIN(solary)], $
		scale = [dx, dy], min =1.5, max = 2.5
	TVLCT, rr, gg, bb
endif

skipit:

end
