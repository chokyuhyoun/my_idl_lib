pro IRIS_MOSAIC2FITS, file

;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine writes the FITS file
;
;
;
;-


scaled=1
RESTGEN, file = file, suncube, solarx, solary, lambda_ref, ref_wave, ref_prof, mask, tmask, ymask

outfilefits = STRMID(file, 0, STRPOS(file,'.genx')) + '.fits'
  
;SUNCUBE         FLOAT     = Array[1002, 6011, 100]
;SOLARX          FLOAT     = Array[1002]
;SOLARY          FLOAT     = Array[6011]
;LAMBDA_REF      DOUBLE    =        2796.3259
;REF_WAVE        DOUBLE    = Array[100]
;REF_PROF        FLOAT     = Array[100]


l2d = STRMID(file, 0, STRPOS(file,'IRISM'))+"level2"
ff=file_list(l2d,'*raster*.fits')
mreadfits,ff,hd,/nodat  


scube = SIZE(suncube)

cdelt1 = solarx[1:*] - solarx[0:-2]
temp = MOMENT(cdelt1, maxmoment=2, mean=meant, sdev=sdevt)
if sdevt*10 gt meant then BOX_MESSAGE,['huge variation in solarx','continuing anyway']
cdelt1 = meant
crpix1 = scube[1]/2 + 1	;	CRPIX starts with 1, not 0
crval1 = solarx[crpix1-1]

cdelt2 = solary[1:*] - solary[0:-2]
temp = MOMENT(cdelt2, maxmoment=2, mean=meant, sdev=sdevt)
if sdevt*10 gt meant then box_message,['huge variation in solary','continuing anyway']
cdelt2 = meant
crpix2 = scube[2]/2 + 1
crval2 = solary[crpix2-1]

cdelt3 = REF_WAVE[1:*] - REF_WAVE[0:-2]
temp = MOMENT(cdelt3, maxmoment=2, mean=meant, sdev=sdevt)
if sdevt*10 gt meant then box_message,['huge variation in ref_wave','continuing anyway']
cdelt3 = meant
crpix3 = scube[3]/2 + 1
crval3 = ref_wave[crpix3-1]

tzeros = WHERE(tmask eq 0, comp = tsomething)
tmin = MIN(tmask[tsomething])
date_obs = TAI2UTC(tmin, /ccsds)
date_end = TAI2UTC(MAX(tmask), /ccsds)
ttmask = FLOAT(tmask - tmin)
ttmask[tzeros] = !values.f_nan

;scale the data to a signed integer if desired
missing = WHERE(FINITE(suncube) eq 0, cmissing)
saturated = WHERE(ABS(suncube) eq !values.f_infinity, csaturated)
if KEYWORD_SET(scaled) then begin
	suncube = (-199) > suncube < (16382-200)
	suncube = FIX(ROUND((suncube+200) * 4 - 32768))
	if cmissing gt 0 then suncube[missing] = -32768
	if csaturated gt 0 then suncube[saturated] = 32764
	bscales=0.25
	bzeros=7992
endif else begin
	bscales=1
	bzeros=0
endelse
cmissing = cmissing - csaturated

;create mainheader
mkhdr, mainheader, suncube, /extend

sxaddpar, mainheader, 'BSCALE', bscales, format="f4.2";, ' True_value = BZERO + BSCALE*Array_value', after='BZERO'
sxaddpar, mainheader, 'BZERO', bzeros;, ' True_value = BZERO + BSCALE*Array_value', after='BTYPE'

fxaddpar, mainheader, 'DATE_OBS', date_obs
fxaddpar, mainheader, 'DATE_END', date_end

fxaddpar, mainheader, 'CDELT1', cdelt1
fxaddpar, mainheader, 'CDELT2', cdelt2
fxaddpar, mainheader, 'CDELT3', cdelt3

fxaddpar, mainheader, 'CRPIX1', crpix1
fxaddpar, mainheader, 'CRPIX2', crpix2
fxaddpar, mainheader, 'CRPIX3', crpix3

fxaddpar, mainheader, 'CRVAL1', crval1
fxaddpar, mainheader, 'CRVAL2', crval2
fxaddpar, mainheader, 'CRVAL3', crval3

fxaddpar, mainheader, 'CTYPE1', 'Solar X'
fxaddpar, mainheader, 'CTYPE2', 'Solar Y'
fxaddpar, mainheader, 'CTYPE3', 'Wavelength'

fxaddpar, mainheader, 'CUNIT1', 'arcsec'
fxaddpar, mainheader, 'CUNIT2', 'arcsec'
fxaddpar, mainheader, 'CUNIT3', 'Angstrom'

fxaddpar,mainheader,'OBSID',hd(0).obsid
fxaddpar,mainheader,'SUMSPAT',hd(0).sumspat
fxaddpar,mainheader,'EXPTIME',hd(0).exptime
fxaddpar,mainheader,'SUMSPTRN',hd(0).sumsptrn
fxaddpar,mainheader,'SUMSPTRF',hd(0).sumsptrf

fxaddpar, mainheader, 'LAMREF', LAMBDA_REF

;write main block
WRITEFITS, outfilefits, suncube, mainheader
  
;add extension for REF_PROF
MKHDR, header, REF_PROF, /image
SXADDPAR, header, 'REF_PROF', 0, 'REF_PROF (rowindex)'
WRITEFITS, outfilefits, REF_PROF, header, /append

; add extension for tmask
MKHDR, theader, ttmask, /image
SXADDPAR, theader, 'T_MASK', 0, 'T_MASK (seconds from date_obs)'
WRITEFITS, outfilefits, ttmask, theader, /append

; add extension for ymask
MKHDR, yheader, ymask, /image
SXADDPAR, yheader, 'Y_MASK', 0, 'Y_MASK (Y coordinate in lev2 frame)'
WRITEFITS, outfilefits, ymask, yheader, /append

end

