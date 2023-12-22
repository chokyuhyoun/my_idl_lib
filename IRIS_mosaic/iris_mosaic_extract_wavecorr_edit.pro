pro IRIS_MOSAIC_EXTRACT_WAVECORR_EDIT, dir, result, $
	silent = silent, nosave = nosave

;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine performs wavelength correction 
; by fitting neutral line positions (mostly just a wrapper for iris_prep_wavecorr_l2)
; It makes a file called 
;			<dir>/YYYYMMDD_IRIS_Mosaic_Corrections.genx
;
; INPUT:
;	dir		-	Full path to the top-level directory for the IRIS Mosaic.
;
; OUTPUT:
;	result	-	The wavelength correction structure (also written to a genx file)
;
; KEYWORDS:
;	/silent	-	If not set, then the corrections are plotted over a set of fits
;	/nosave	-	If set, then the result is returned in the output variable but not saved
;
;
;-

if not KEYWORD_SET(silent) then silent = 0
datestr = FILE_BASENAME(dir)
ofile 	= CONCAT_DIR(dir, datestr + '_IRIS_Mosaic_Corrections.genx')
files = FILE_SEARCH(CONCAT_DIR(dir, 'level2/iris_l2_*.fits'), count = npoint)

result = IRIS_PREP_WAVECORR_L2(files, /nosine)
stop
result.corr_nuv = MEDIAN(result.corr_nuv, 200)
result.corr_fuv = MEDIAN(result.corr_fuv, 200)

if not KEYWORD_SET(nosave) then SAVEGEN, file = ofile, str = result

; Store display settings
TVLCT, rr, gg, bb, /get
old_device = !d.name
old_p = !p

; Generate a plot in the Z-buffer and write it to a PNG file
SET_PLOT, 'Z', /copy
DEVICE, z_buff = 0, set_resolution = [1000, 700]
!p.multi = [0, 1, 2]
LOADCT, 12, /silent
TVLCT, rrr, ggg, bbb, /get
bluecol		= 110
redcol 		= 200
greencol	= 50
forecol 	= 255
!p.color 	= forecol	;	UTPLOT requires this for the axis...yuck

cnuv = result.corrs[*,*,0:2]
cnfin = WHERE(FINITE(cnuv), numfin)
if numfin gt 0 then begin
	yrange = LIMITS(cnuv[cnfin])
	UTPLOT, result.times, result.corrs[*,*,0], yrange = yrange, psym = 4, chars = 1.5, $
		ytitle = 'Wavelength error (' + STRING(197B) + ')', /xstyle, $
		title = 'NUV wavelength correction', col = forecol
	OUTPLOT, result.times, result.corrs[*,*,1], psym = 4, col = greencol
	OUTPLOT, result.times, result.corrs[*,*,2], psym = 4, col = bluecol
	OUTPLOT, TAI2UTC(result.corr_tai), result.corr_nuv, col = redcol, thick = 2, line = 2
	AL_LEGEND, result.lname[0:2], col = [forecol, greencol, bluecol], psym = [4,4,4], $
		/top, /left, chars = 1.5
endif

cfuv = result.corrs[*,*,3:4]
cffin = WHERE(FINITE(cfuv), numfin)
if numfin gt 0 then begin
	yrange = LIMITS(cfuv[cffin])
	UTPLOT, result.times, result.corrs[*,*,3], yrange = yrange, psym = 4, chars = 1.5, $
		ytitle = 'Wavelength error (' + STRING(197B) + ')', /xstyle, $
		title = 'FUV wavelength correction', col = forecol
	OUTPLOT, result.times, result.corrs[*,*,4], psym = 4, col = greencol
	OUTPLOT, TAI2UTC(result.corr_tai), result.corr_fuv, col = redcol, thick = 2, line = 2
	AL_LEGEND, result.lname[3:4], col = [forecol, greencol], psym = [4,4], $
		/top, /left, chars = 1.5
endif

wavecorr_win = TVRD()
if not KEYWORD_SET(nosave) then WRITE_PNG, CONCAT_DIR(dir, 'figs/wavecorr.png'), wavecorr_win, rrr, ggg, bbb

; Display the image in an X window
if not silent then begin
	SET_PLOT, 'X', /copy
	WDEF, 10, 1000, 700
	TV, wavecorr_win
endif

; Reset display settings
SET_PLOT, old_device
!p = old_p
TVLCT, rr, gg, bb

end
