PRO sexfind, image, x, y, flux, fluxerr, fwhm, elongation, $
   sexconfig = sexconfig, autoflux = autoflux, options = options


; 
; NAME 
;	sexfind
;
; PURPOSE
; 	Use SExtractor to find objects and obtain x/y positions and 
;	fluxes.  This is to replace find.pro for better photometry.
;
; INPUTS
;	image - image to detect objects
;
; OUTPUT
;	x,y - image positions of detected objects, in IDL convension.
;	flux,fluxerr - fluxes and associated errors of detected objects.
;	fwhm - image fwhm of detected objects.
;	elongation - elongation of the objects.
;
; OPTIONAL PARAMETERS
;	sexconfig - string, configuration file name for sextractor.
;		   Default is 'sexfind.default'.
;	autoflux - When set to 0 (default), will use aperture fluxes. 
;	       If set to 1, will use auto-aperture fluxes.
;   options - string, sextractor options.  Use the same syntax as 
;          the command-line sextractor.   
;
; NOTE:
;	The configuration file (sexconfig) for SExtractor needs to be 
;	provided externally.  In addition, an output parameter file
;	needs to be provided and specified in the configuration file
;	(default is 'PARAMETERS_NAME sexfind.param').  Currently the 
;	parameters are NUMBER, X_IMAGE, Y_IMAGE, FLUX_APER, FLUXERR_APER, 
;	FLUX_AUTO, FLUXERR_AUTO, FWHM_IMAGE, and ELONGATION.  In this 
;	version, users can choose to use aperture fluxes or SExtractor's
;	auto-aperture fluxes.  The aperture size (and many other 
;	configurations) is specified in the configuration file.  
;	
; VERSION
;	1.0, 20050709 by WHWANG
;   	1.1, 20060115 by WHWANG
;	1.2, 20060522 by WHWANG
;

cd, current=c
cd, '/data/home/chokh/sextractor-2.19.5'

IF n_elements(autoflux) EQ 0 THEN autoflux = 0
IF n_elements(sexconfig) EQ 0 THEN sexconfig = 'sexfind.default'
IF n_elements(silent) EQ 0 THEN silent = 0
IF n_elements(thres) EQ 0 THEN thres = 3
IF n_elements(options) EQ 0 THEN options = ''

; use bg rms value and a random number to name the temp file

imsize = size(image,/dimen)
sky, image[0.35*imsize[0]:0.65*imsize[0], 0.35*imsize[1]:0.65*imsize[1]], bg, rms, /nan, /silent
filename = 'sexfind'+strtrim((round(rms*abs(randomn(seed,1))*10.0^(fix(6.0-alog10(rms))))),2)

image2 = image
A = where(finite(image) EQ 0)
IF total(A) GT -1 THEN image2[A] = bg
mwrfits, image2, filename+'.fits', /create

spawn, 'sex '+filename+'.fits -c '+sexconfig+ $
            ' -CATALOG_NAME '+filename+'.txt '+options
stop
spawn, 'rm '+filename+'.fits'

file_move, filename+'.txt', c

array=read_ascii(filename+'.ASC', array, 9, nskip=9)
x = reform(array[1,*])-1
y = reform(array[2,*])-1
flux = reform(array[3,*])
fluxerr = reform(array[4,*])
IF autoflux EQ 1 THEN flux = reform(array[5,*])
IF autoflux EQ 1 THEN fluxerr = reform(array[6,*])
fwhm = reform(array[7,*])
elongation = reform(array[8,*])


spawn, 'rm '+filename+'.ASC'

END
