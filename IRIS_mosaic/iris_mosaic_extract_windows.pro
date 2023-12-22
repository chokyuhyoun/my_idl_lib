pro IRIS_MOSAIC_EXTRACT_WINDOWS, dir, winname, $
	clipy = clipy, silent = silent

;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine gathers all the rasters and regrids
; them onto a reference wavelength grid, adjusting for shifts in neutral line 
; position
;
; INPUT:
;	dir		-	Full path to the top-level directory for the IRIS Mosaic.
;	winname	-	String describing the spectral window for which to run
;
;		This routine will make a file called 
;			<dir>/YYYYMMDD_IRIS_Mosaic_Slices_<winname>.genx
;
; KEYWORDS:
;
;-

datestr = FILE_BASENAME(dir)
date = FILE2TIME(datestr)
xx = PB0R(date, /arcsec, /earth)

corrfile = CONCAT_DIR(dir, datestr + '_IRIS_Mosaic_Corrections.genx')
if FILE_EXIST(corrfile) eq 0 then MESSAGE, 'Correction File Not Found - Stopping'
RESTGEN, file = corrfile, str = wavecorr
ofile = CONCAT_DIR(dir, 'slices/' + datestr + '_IRIS_Mosaic_Slices_'+winname+'.genx')

; Find all the lev2 files, and read the first one
f = FILE_SEARCH( CONCAT_DIR(dir, 'level2/iris_l2_*.fits'), count = fc)
d = IRIS_OBJ(f[0])

; Set up the parameters for this spectral window:
;	winid	-	Index of the window in the lev2 file
;	dlambda	-	Wavelength range in Angstroms for the mosaic
;	newlambdascale - Number of pixels to use to span the wavelength range
;	dvx	-	Wavelength offset [A] of the red/blue wings to use for doppler maps
;	lambda_ref	-	Reference wavelength for the line

windaes         = ['MgIIh',       'MgIIk',        'Si1393',  'Si1403',  'C1334',  'C1335']	;	Possible values
;lambda_refs     = [2803.5047192d, 2796.3259493d,  1393.78,   1402.77,   1334.60,  1335.80]	;	Scott's original values
lambda_refs     = [2803.530d, 	2796.352d,  	1393.76,   1402.77,   1334.53,  1335.71]	;	Values from ITN 26 ref spectra
dvxs            = [0.35,          0.35,           0.15,      0.15,      0.15,     0.15]
newlambdascales = [100,           100,            40,        40,        40,       40]
dlambdas        = [1.75,          1.75,           0.5,       0.5,       0.5,      0.5]

jj = (WHERE(winname eq windaes))[0]
lambda_ref = lambda_refs[jj]
dvx = dvxs[jj]
newlambdascale = newlambdascales[jj]
dlambda = dlambdas[jj]
winid = d -> GETWINDX(lambda_ref)
clip = lambda_ref + dlambda*[-1,1]
tjd = ANYTIM2JD(TAI2UTC(wavecorr.corr_tai))
times_jd = tjd.int + tjd.frac

; Define a fixed wavelength grid based on the above
wavestep = 2d * dlambda / newlambdascale
ref_wave = DINDGEN(newlambdascale+1) * wavestep + lambda_ref - dlambda

; Store display settings
TVLCT, rr, gg, bb, /get
old_device = !d.name
old_p = !p

; Set up to plot the mosaic positions as you go
SET_PLOT, 'Z', /copy
DEVICE, z_buff = 0, set_resolution = [700, 700]
solx = (FINDGEN(110)-54)*20
LOADCT, 0, /silent
TVLCT, rrr, ggg, bbb, /get
PLOT, solx, solx, xtit = 'Solar X [arcsec]', ytit = 'Solar Y [arcsec]', /nodata,$
	xst = 1, yst = 1
TVCIRCLE, xx[2], 0., 0., color = 255, lines = 1

for ii = 0, fc-1 do begin

	l2f = f[ii]
	d=OBJ_NEW('iris_data')
	d->READ, l2f
	index = d->GETHDR(/struct)

	solarx=d->GETXPOS()
	xfac = [MEAN(solarx), MEAN(DERIV(solarx))]
	nx = N_ELEMENTS(solarx)
	solary=d->GETYPOS()
	yfac = [MEAN(solary), MEAN(DERIV(solary))]
	ny = N_ELEMENTS(solary)
	tt = d->GETTIME()
	tt = tt + ANYTIM2TAI(index.date_obs)
	tmp = FLTARR(newlambdascale+1, nx, ny)
	line_pos = FLTARR(nx)

	; Plot mosaic location as you go
	XYOUTS, MEAN(solarx), MEAN(solary), FNS('###',ii), align = 0.5, $
		/data, chars = 0.75
	xxx = [MIN(solarx), MAX(solarx), MAX(solarx), MIN(solarx), MIN(solarx)]
	yyy = [MIN(solary), MIN(solary), MAX(solary), MAX(solary), MIN(solary)]
	PLOTS, xxx, yyy, lines = 2

	; Set up output variables on first pass
	if ii eq 0 then begin
;		wave=d->GETLAM(winid)
;		bw = WHERE((wave ge clip[0]) and (wave le clip[1]), bwcnt)
;		wave = wave[bw]
;		ref_wave = INTERPOL(wave, newlambdascale)
		output = FLTARR(newlambdascale+1, fc * nx, ny)
		toutput = DBLARR(fc * nx)
		coord = FLTARR(2,fc * nx, ny)
		fitpos = DBLARR(fc * nx)
		corrtime = wavecorr.corr_tai
	endif

	data = d->GETVAR(winid,/load)
	data = TRANSPOSE(data, [0, 2, 1])
	wave=d->GETLAM(winid)

	bot = ii*nx
	if lambda_ref gt 2000. then begin
		correction = INTERPOL(wavecorr.corr_nuv, wavecorr.corr_tai, tt)
	endif else begin
		correction = INTERPOL(wavecorr.corr_fuv, wavecorr.corr_tai, tt)
	endelse

	; Loop through the images in this raster
	for rr = 0, nx-1 do begin
		adj_wave = wave + correction[rr]
		bw = WHERE((adj_wave ge clip[0]) and (adj_wave le clip[1]), bwcnt)
		; Loop through spatial pixels in this image and regrid spectrum
		for pp = 0, ny-1 do begin
			spec = REFORM(data[bw, rr, pp])
			new_spec = INTERPOL(spec, adj_wave[bw], ref_wave)* n_elements(bw)/(newlambdascale+1);aug9,2017 normalized spectral bin DN
			cont_level = MEAN([new_spec[0:5], new_spec[newlambdascale-5:newlambdascale]])	;	Not used?
			tmp[*, rr, pp] = new_spec
		endfor
		; Sum spectrum along the slit and fit line center
		tmp_prof = TOTAL(REFORM(DOUBLE(tmp[*,rr,*])),2)
		if MEAN(tmp_prof) ge 1 then begin
		xxx = MPFITPEAK(ref_wave, tmp_prof, nterms = 4, fitpars)
		if fitpars[1] le MIN(ref_wave) or fitpars[1] ge MAX(ref_wave) then fitpars[1] = lambda_ref
		line_pos[rr] = fitpars[1]
		endif
	endfor

   output[*, bot:bot+nx-1, *] = tmp
   toutput[bot:bot+nx-1] = tt
   for pp = 0, ny-1 do coord[0,bot:bot+nx-1,pp] = solarx
   for pp = 0, nx-1 do coord[1,bot+pp,*] = solary
   fitpos[bot:bot+nx-1] = line_pos

endfor

y_data = [0, ny-1]
clipy = y_data
output = REFORM(output[*,*,clipy[0]:clipy[1]])
coord = REFORM(coord[*,*,clipy[0]:clipy[1]]) 

bad = WHERE(FINITE(output) eq 0, numbad)
if numbad gt 0 then output[bad] = 0.

aa = SIZE(output)
prof = TOTAL(output,2)/FLOAT(aa[2])		;	Average spectral window (lam x Y)
ref_prof = TOTAL(prof,2)/FLOAT(aa[3])	;	Average spectrum (lam)
fit_prof = MPFITPEAK(ref_wave, ref_prof, nterms = 4, fitpars)

zero_position = fitpars[1]
blue_pos = zero_position - dvx ; 
red_pos = zero_position + dvx
red_wing = MIN(ABS(ref_wave - red_pos), rwp)
blue_wing = MIN(ABS(ref_wave - blue_pos), bwp)
cent_pos = MIN(ABS(ref_wave - zero_position), cp)

; Grab the image with the mosaic locations, then reset display settings
tileimg = TVRD()
WRITE_PNG, CONCAT_DIR(dir, 'figs/' + winname + '_tileimg.png'), tileimg, rrr, ggg, bbb
SET_PLOT, old_device
!p = old_p
;TVLCT, rr, gg, bb

; These other plots are only made if /silent is not set
if not KEYWORD_SET(silent) then begin
	; Display the tileimg plot that was saved
	LOADCT, 0, /silent
	WINDOW, 0, xs = 700, ys = 700
	TV, tileimg
	; Set up to make some other plots; not that useful
	WINDOW, 1, xs = 2000, ys = 400
	WINDOW, 2, xs = 512, ys = 512
	date_label = LABEL_DATE(DATE_FORMAT = ['%N/%D!C%H:%I'])
	LOADCT, 3, /silent

	for ii =0, N_ELEMENTS(windaes)-1 do begin
	   WSET, 1
	   PIH, ALOG10(output[ii, *, *]), min = 1, max = 3., /nosq, origin = [MIN(times_jd), 0.],$
		 scale = [MEAN(DERIV(times_jd)), MEAN(DERIV(solary))], xtickunits = 'Time', XTICKFORMAT = 'LABEL_DATE',$
		 xtickinterval = 2, chars = 1.5

	   WSET, 2
	   PLOT, ref_wave, ref_prof, xst = 1, xtit = 'Wavelength ['+STRING(197B)+']'
	   PLOTS, ref_wave[ii]*[1,1], !y.crange, lines = 2
	endfor

	WSET, 2
	PLOT, ref_wave, ref_prof, xst = 1, xtit = 'Wavelength ['+STRING(197B)+']', psym = 5
	OPLOT, ref_wave, fit_prof, lines = 3
	fitprofimage = TVRD(/true)
	WRITE_PNG, CONCAT_DIR(dir, 'figs/IRISMosaic_' + winname + '_prof.png'), fitprofimage
	EMPTY
	TVLCT, rr, gg, bb
endif

SAVEGEN, file = ofile, output, coord, ref_wave, ref_prof, zero_position, $
	red_pos, blue_pos, lambda_ref, rwp, bwp, cp, fitpos, toutput, $
	names = ['output', 'coord', 'ref_wave', 'ref_prof', 'zero_position', $
		'red_pos', 'blue_pos', 'lambda_ref', 'rwp', 'bwp', 'cp', 'fitpos', 'toutput']

end

