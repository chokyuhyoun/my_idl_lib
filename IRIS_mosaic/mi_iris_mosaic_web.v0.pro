pro IRIS_MOSAIC_WEB, dir, $
	windaes = windaes, pstop = pstop, $
	nojpg = nojpg, nosdofits = nosdofits, nosdojpgs = nosdojpgs, $
	nocopy = nocopy, nohtml = nohtml, $
	add_kludge = add_kludge, nodoppler = nodoppler, $
	gamma_val = gamma_val

	
;+
;
; Part of IRIS_MOSAIC_MAKER suite; this routine copies the results to the public
; directories and updates the web page to make them visible. 
;
; INPUT:
;	dir		-	Full path to the top-level directory for the IRIS Mosaic.
;
; KEYWORDS:
;	/nojpg	 -	If not set, then generate 1000x1000 and 64x64 jpg files for the
;				line center and dopplergram of each window
;	/nosdofits - If not set, then generate FITS files for the SDO frankenmaps
;	/nocopy	-	If not set, then copy the files into place on /irisa/data/mosaic
;	/nohtml	-	If not set, then generate some html and write it to the mosaic_test.html
;				file
;	/nodoppler	-	If not set, then generate some dopplergrams in addition to the 
;				line core jpgs.
;	add_kludge=	-	Set to a constant to add to the images to adjust the overall level
;
;
;-

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

; Set up constants and defaults
if N_ELEMENTS(dir) eq 0 then dir = '/Volumes/disk2/data/iris/mosaic/20130930'
datestr = FILE_BASENAME(dir)
if N_ELEMENTS(windaes) eq 0 then windaes = ['MgIIh','MgIIk','Si1393','Si1403','C1334', 'C1335']
numwin = N_ELEMENTS(windaes)
sizes = [1000, 64]
numsize = N_ELEMENTS(sizes)
all_windaes         = ['MgIIh',       'MgIIk',        'Si1393',  'Si1403',  'C1334',  'C1335']	;	Possible values
all_lambda_refs     = [2803.530d, 	2796.352d,  	1393.76,   1402.77,   1334.53,  1335.71]	;	Values from ITN 26 ref spectra
all_dvxs            = [0.35,          0.35,           0.15,      0.15,      0.15,     0.15]

; Set up the subdirs in the output area
online_base = '/irisa/data/mosaic'
online_dir = CONCAT_DIR(online_base, datestr)
jpg_dir = CONCAT_DIR(online_dir, 'jpg')
fits_dir = CONCAT_DIR(online_dir, 'fits')
png_dir = CONCAT_DIR(online_dir, 'png')
if not FILE_EXIST(online_dir) then SPAWN, 'mkdir ' + online_dir, result, errcode
if not FILE_EXIST(jpg_dir) then SPAWN, 'mkdir ' + jpg_dir, result, errcode
if not FILE_EXIST(fits_dir) then SPAWN, 'mkdir ' + fits_dir, result, errcode
if not FILE_EXIST(png_dir) then SPAWN, 'mkdir ' + png_dir, result, errcode

; Store display settings
TVLCT, rr, gg, bb, /get
save, rr, gg, bb, filename = 'rgb_ini_webmosaic.sav'
old_device = !d.name
old_p = !p

; Generate JPEGs and thumbnails for each channel
if not KEYWORD_SET(nojpg) then for i = 0, numwin - 1 do begin
	fitsfile = CONCAT_DIR(dir, 'IRISMosaic_' + datestr + '_' + windaes[i] + '.fits')
	if not FILE_EXIST(fitsfile) then begin
		if FILE_EXIST(fitsfile + '.gz') then begin
			PRINT, 'IRIS_MOSAIC_WEB: gunzipping ' + fitsfile
			SPAWN, 'gunzip ' + fitsfile + '.gz', result, errcode
			MREADFITS, fitsfile, hdr, dat
		endif else begin
			PRINT, 'IRIS_MOSAIC_WEB: File missing!'
		endelse
	endif else begin
		MREADFITS, fitsfile, hdr, dat
	endelse
	if N_ELEMENTS(add_kludge) gt 0 then dat = dat + add_kludge
	coreind = hdr[0].naxis3 / 2
	coreimg = dat[*,*,coreind]
	darkpix = WHERE(coreimg lt 1, numdark)
	if numdark le 0 then STOP
	darkfrac = DOUBLE(numdark) / N_ELEMENTS(coreimg)
	darktarget = darkfrac - 0.15	;	Fraction of image outside the disk
	coreimg[darkpix] = !values.f_nan
	case windaes[i] of
		'MgIIh'	:	begin
			lct_comm = 'IRIS_LCT, {img_path : "NUV"}'
			sclimg = IRIS_INTSCALE(coreimg, img_path = 'FUV', maxfrac = 0.999, minfrac = darktarget)
			wingbin = ROUND(0.35 / hdr[0].cdelt3)
			wingthresh = 50
		end
		'MgIIk'	:	begin
			lct_comm = 'IRIS_LCT, {img_path : "NUV"}'
			sclimg = IRIS_INTSCALE(coreimg, img_path = 'FUV', maxfrac = 0.998, minfrac = darktarget)
			wingbin = ROUND(0.35 / hdr[0].cdelt3)
			wingthresh = 70
		end
		'Si1393'	:	begin
			lct_comm = 'LOADCT, 8, /silent'
			sclimg = IRIS_INTSCALE(coreimg, img_path = 'FUV', maxfrac = 0.998, minfrac = 0.2)
			wingbin = ROUND(0.15 / hdr[0].cdelt3)
			wingthresh = 60
		end
		'Si1403'	:	begin
			lct_comm = 'LOADCT, 8, /silent'
			sclimg = IRIS_INTSCALE(coreimg, img_path = 'FUV', maxfrac = 0.998, minfrac = 0.2)
			wingbin = ROUND(0.15 / hdr[0].cdelt3)
			wingthresh = 40
		end
		'C1334'	:	begin
			lct_comm = 'IRIS_LCT, {img_path : "FUV"}'
			sclimg = IRIS_INTSCALE(coreimg, img_path = 'FUV', maxfrac = 0.997, minfrac = 0.15)
			wingbin = ROUND(0.15 / hdr[0].cdelt3)
			wingthresh = 30
		end
		'C1335'	:	begin
			lct_comm = 'IRIS_LCT, {img_path : "FUV"}'
			sclimg = IRIS_INTSCALE(coreimg, img_path = 'FUV', maxfrac = 0.997, minfrac = 0.15)
			wingbin = ROUND(0.15 / hdr[0].cdelt3)
			wingthresh = 50
		end
		else	:	PRINT, 'wtf??'
	endcase
	wingind = coreind + [-1, 1] * wingbin
	doppimg = dat[*,*,wingind[1]] - dat[*,*,wingind[0]]

	SET_PLOT, 'Z', /copy
	DEVICE, z_buff = 0
        	
	for j = 0, numsize - 1 do begin
		thissize = sizes[j]
		DEVICE, set_resolution = [thissize, thissize]
		; Make line center intensity JPG
		dummy = EXECUTE(lct_comm)
		TVLCT, rrr, ggg, bbb, /get
		if KEYWORD_SET(gamma_val) then begin
		   print, windaes[i]	
		   r_curr = rrr
		   g_curr = ggg
		   b_curr = bbb
		   gamma_ct, gamma_val[i], /curr
		   rrr = r_curr
		   ggg = g_curr
		   bbb = b_curr
	        endif   
		TVLCT, rrr, ggg, bbb
		TV, CONGRID(sclimg, thissize, thissize)
		corwin = TVRD()
		cortru = BYTARR(3, thissize, thissize)
		cortru[0,*,*] = rrr[corwin]
		cortru[1,*,*] = ggg[corwin]
		cortru[2,*,*] = bbb[corwin]
		corjpg = CONCAT_DIR(dir, 'jpgs/IRISMosaic_' + datestr + '_' + $
			windaes[i] + '_core_' + STRTRIM(thissize, 2) + '.jpg')
		WRITE_JPEG, corjpg, cortru, quality = 80, /true
		if not KEYWORD_SET(nocopy) then SPAWN, 'cp ' + corjpg + ' ' + jpg_dir, result, errcode
		; Make dopplergram JPG
		IRIS_MOSAIC_DOPPLER, /load
		TVLCT, rrr, ggg, bbb, /get
		TV, BYTSCL(CONGRID(doppimg, thissize, thissize), $
			min = 0-wingthresh, max = wingthresh, top = 253) + 1
		dopwin = TVRD()
		doptru = BYTARR(3, thissize, thissize)
		doptru[0,*,*] = rrr[dopwin]
		doptru[1,*,*] = ggg[dopwin]
		doptru[2,*,*] = bbb[dopwin]
		dopjpg = CONCAT_DIR(dir, 'jpgs/IRISMosaic_' + datestr + '_' + $
			windaes[i] + '_doppler_' + STRTRIM(thissize, 2) + '.jpg')
		WRITE_JPEG, dopjpg, doptru, quality = 80, /true
		if not KEYWORD_SET(nocopy) then SPAWN, 'cp ' + dopjpg + ' ' + jpg_dir, result, errcode
	endfor
	
	DEVICE, z_buff = 1
	
endfor

; Generate FITS files for each SDO image in the FrankenMap
if not KEYWORD_SET(nosdofits) then begin
	frankenfile = CONCAT_DIR(dir, datestr + '_IRIS_FrankenMaps_SDO.genx')
	RESTGEN, file = frankenfile, str = allmaps
	drmsfile = CONCAT_DIR(dir, 'lev1_drms.genx')
	RESTGEN, file = drmsfile, alldrms
	date_obs = alldrms[0].t_obs
	date_end = alldrms[-1].t_obs
	sdo_template = {origin : 'SDO', exptime : 1., wavelnth : 1, $
		crpix1 : 2048.5, crval1 : 0., cdelt1 : 0.6, cunit1 : 'arcsec', $
		crpix2 : 2048.5, crval2 : 0., cdelt2 : 0.6, cunit2 : 'arcsec', $
		crota2 : 0., xcen : 0., ycen : 0., $
		date_obs : date_obs, date_end : date_end, $
		t_obs : TAI2UTC(/ccsds, MEAN([ANYTIM2TAI(date_obs), ANYTIM2TAI(date_end)])) }
	sdotags = TAG_NAMES(allmaps)
	for i = 0, N_ELEMENTS(sdotags) - 1 do begin
		thisfits = CONCAT_DIR(dir, 'SDO/' + datestr + '_' + sdotags[i] + '.fits')
		thishdr = sdo_template
		if STRMID(sdotags[i], 0, 3) eq 'HMI' then thishdr.wavelnth = 6173 $
			else thishdr.wavelnth = FIX(STRMID(sdotags[i], 4, 4))
		WRITEFITS, thisfits, allmaps.(i).data, STRUCT2FITSHEAD(thishdr)
		if not KEYWORD_SET(nosdojpgs) then begin
			SET_PLOT, 'Z', /copy
			DEVICE, z_buff = 0
			DEVICE, set_resolution = [1000, 1000]
			AIA_LCT, wave = thishdr.wavelnth, /load
			sclimg = AIA_INTSCALE(/byte, /exptime, wave = thishdr.wavelnth, allmaps.(i).data)
			TVLCT, rrr, ggg, bbb, /get
			TV, CONGRID(sclimg, 1000, 1000)
			corwin = TVRD()
			cortru = BYTARR(3, 1000, 1000)
			cortru[0,*,*] = rrr[corwin]
			cortru[1,*,*] = ggg[corwin]
			cortru[2,*,*] = bbb[corwin]
			corjpg = FILE_BASENAME(thisfits, '.fits')
			corjpg = CONCAT_DIR(dir, 'jpgs/' + corjpg + '.jpg')
			WRITE_JPEG, corjpg, cortru, quality = 80, /true
			DEVICE, z_buff = 1
			if not KEYWORD_SET(nocopy) then SPAWN, 'cp ' + corjpg + ' ' + jpg_dir, result, errcode
		endif
	endfor
endif

; Copy the FITS and PNG files into place
if not KEYWORD_SET(nocopy) then begin
	; Copy the IRIS mosaic FITS files into place
	for i = 0, numwin - 1 do begin
		fitsfile = CONCAT_DIR(dir, 'IRISMosaic_' + datestr + '_' + windaes[i] + '.fits')
		SPAWN, 'cp ' + fitsfile + ' ' + fits_dir, result, errcode
	endfor
	; Copy the SDO FITS files into place
	sdofits = FILE_SEARCH(CONCAT_DIR(dir, 'SDO/*.fits'))
	for j = 0, N_ELEMENTS(sdofits) - 1 do begin
		SPAWN, 'cp ' + sdofits[j] + ' ' + fits_dir, result, errcode
	endfor
	; Copy the PNG figures into place
	pngs = FILE_SEARCH(CONCAT_DIR(dir, 'figs/*.png'))
	for j = 0, N_ELEMENTS(pngs) - 1 do begin
		SPAWN, 'cp ' + pngs[j] + ' ' + png_dir, result, errcode
	endfor
endif

; Write some HTML to incorporate the results
if not KEYWORD_SET(nohtml) then begin
	; Set up some constants defining the geometry of the table
	donedates = FILE_SEARCH(CONCAT_DIR(online_base, '20??????'))	;	Dates with directories online
	numdate = N_ELEMENTS(donedates)			;	Number of dates in the table
	tabwidth = 950			;	Width of the table in pixels
	rowheight = 52			;	Height of the rows in the table
	thumbsize = 50			;	Pixel size of the thumbnail images
	tabpad = 3				;	Padding around the table border in pixels
	datewidth = 150			;	Width of the first (date) column, in pixels
	linesep = 20			;	Pixels between image pairs from different lines
	dopsep = 7				;	Pixels between the doppler and the line-center image
	tabheight = (numdate -1) * (rowheight + 20) + 50	;	Height of the table in pixels
	titleheight = rowheight - 10

	if KEYWORD_SET(nodoppler) then begin
		rowheight = 83
		thumbsize = 81
		dopsep = 25
		linesep = -99
		tabheight = tabheight + (numdate * 31.)
		tabwidth = 850
		titleheight = 45
	endif
	
	html_start = '<!-- This is the start of the content for the mosaic page -->'
	html_autostart = '<!-- This is the start of the auto-content for the mosaic page -->'
	html_autoend = '<!-- This is the end of the auto-content for the mosaic page -->'
	html_end = '<!-- This is the end of the content for the mosaic page -->'
;	html_leadin = '<p style="width:' + STRTRIM(tabwidth, 2) + 'px"> This is the web page for IRIS mosaics. FITS files can be accessed by clicking on the date links in the table below. Instructions for reading and interpreting the FITS files follow the table.</p>'
	html_tabstart = '<div style="width:' + STRTRIM(tabwidth, 2) + 'px; height:' + STRTRIM(tabheight, 2) + 'px; border:1px solid red; padding:' + STRTRIM(tabpad, 2) + 'px;">'
	html_rowend = '</div>'
	html_rowclear = '<p style="clear: both;">'
	;;; Mod. Migration to AWS - 20200113 (ASD)
	    html_base = 'http://www.lmsal.com/solarsoft/irisa/data/mosaic/' 
	    html_base_compressed = 'http://www.lmsal.com/solarsoft/irisa/data/level2_compressed/'
	;;; Mod. Migration to AWS - 20200113 (ASD)
	coltitles = [['Date', 'MgIIh','MgIIk'],['Si IV 1393','Si IV 1403','C II 1334', 'C II 1335'] + ' A']	;	+STRING(197B)

	; Open the current online file and read to the section you want to be at
	pubfile = CONCAT_DIR(online_base, 'mosaic.html')
	print, online_base
	OPENR, olun, /get, pubfile
	thisline = ' '
	htmlfile = CONCAT_DIR(online_base, 'mosaic_test.html')
	OPENW, lun, /get, htmlfile
	while STRTRIM(thisline, 2) ne html_autostart do begin
		READF, olun, thisline
		PRINTF, lun, thisline
	endwhile
	if KEYWORD_SET(pstop) then STOP

	PRINTF, lun
	PRINTF, lun, STRING('', form = '(a12)') + html_tabstart
	PRINTF, lun
	; Loop through lines in the table (including the header line)
	for i = 0, numdate do begin
		; Set up the variables that are going to be printed
		if i eq 0 then begin
			thisheight = titleheight 
		endif else begin
			thisheight = rowheight
			datestr = FILE_BASENAME(donedates[i-1])
	                ;;; Mod. Migration to AWS - 20200113 (ASD)
			    yyyy = strmid(datestr, 0, 4)
			    mm = strmid(datestr, 4, 2)
			    dd = strmid(datestr, 6, 2)
			    format_link = yyyy+'/'+mm+'/'+dd+'/'+datestr+'Mosaic/'
	                ;;; Mod. Migration to AWS - 20200113 (ASD)
			datestring = STRMID(FILE2TIME(datestr), 0, 10)
			online_dir = CONCAT_DIR(online_base, datestr)
			jpg_dir = CONCAT_DIR(online_dir, 'jpg')
			fits_dir = CONCAT_DIR(online_dir, 'fits')
		endelse
		html_rowstart = '<div style="width:' + STRTRIM(tabwidth - 10,2) + 'px; height:' + STRTRIM(thisheight, 2) + 'px; border:0px; padding:2px;">'
		PRINTF, lun, STRING('', form = '(a14)') + html_rowstart
		; Loop through the spectral windows (with 0 being the date)
		for j = 0, numwin do begin
			case 1 of
				j eq 0	:	thiswidth = datewidth 
				i eq 0	:	thiswidth = thumbsize*2 + linesep + dopsep - 7
				else	:	thiswidth = thumbsize
			endcase
			case 1 of
				i eq 0	:	thiscontent = coltitles[j]
				;;; Mod. Migration to AWS - 20200113 (ASD)
				    ; j eq 0	:	thiscontent = '<a href="' + html_base + datestr + '/fits/">' + STRTRIM(datestring, 2) + '</a>'
				    j eq 0	:	thiscontent = '<a href="' + html_base_compressed + format_link +'">' + STRTRIM(datestring, 2) + '</a>'
				else	:	begin
					thisfits = CONCAT_DIR(fits_dir, 'IRISMosaic_' + datestr + '_' + windaes[j-1] + '.fits')
					if FILE_EXIST(thisfits) then begin
						jpg_base = html_base + datestr + '/jpg/IRISMosaic_' + datestr + '_' + windaes[j-1] + '_'
						jpg_file = jpg_base + 'core_1000.jpg'
						thumb_file = jpg_base + 'core_' + STRTRIM(sizes[1], 2) + '.jpg'
						thiscontent = '<a href="' + jpg_file + '"><img style = "width:' + STRTRIM(thumbsize,2) + 'px; height:' + STRTRIM(thumbsize,2) + 'px" src="' + thumb_file + '"></a>'
					endif else begin
						thiscontent = ''
					endelse
				end
			endcase
			thissep = dopsep
			html_thiscell = '<div style="width:' + STRTRIM(thiswidth, 2) + 'px; height:' + STRTRIM(thisheight, 2) + 'px; padding:1px ' + STRTRIM(thissep, 2) + 'px 1px 1px; border:0px solid blue; float:left; line-height:' + STRTRIM(rowheight, 2) + 'px; display:table-cell"><center>' + thiscontent + '</center></div>'
			PRINTF, lun, STRING('', form = '(a16)') + html_thiscell
			; Loop through line center and doppler for each window
			if (i ne 0) and (j ne 0) and (not KEYWORD_SET(nodoppler)) then begin
				thissep = linesep
				if FILE_EXIST(thisfits) then begin
					jpg_file = jpg_base + 'doppler_1000.jpg'
					thumb_file = jpg_base + 'doppler_' + STRTRIM(sizes[1], 2) + '.jpg'
					thiscontent = '<a href="' + jpg_file + '"><img style = "width:' + STRTRIM(thumbsize,2) + 'px; height:' + STRTRIM(thumbsize,2) + 'px" src="' + thumb_file + '"></a>'
				endif else begin
					thiscontent = ''
				endelse
				html_thiscell = '<div style="width:' + STRTRIM(thiswidth, 2) + 'px; height:' + STRTRIM(thisheight, 2) + 'px; padding:1px ' + STRTRIM(thissep, 2) + 'px 1px 1px; border:0px solid blue; float:left; line-height:' + STRTRIM(rowheight, 2) + 'px; display:table-cell"><center>' + thiscontent + '</center></div>'
				PRINTF, lun, STRING('', form = '(a16)') + html_thiscell
			endif
		endfor	
		PRINTF, lun, STRING('', form = '(a14)') + html_rowend
		PRINTF, lun, STRING('', form = '(a14)') + html_rowclear
		PRINTF, lun
	endfor
	PRINTF, lun, STRING('', form = '(a12)') + html_rowend
	PRINTF, lun
	
	; Now write the rest of the stuff in the online file to the end of the new file
	while STRTRIM(thisline, 2) ne html_autoend do begin
		READF, olun, thisline
	endwhile
	PRINTF, lun, thisline
	while not EOF(olun) do begin
		READF, olun, thisline
		PRINTF, lun, thisline
	endwhile

	FREE_LUN, lun
	FREE_LUN, olun
endif

; Restore display settings
SET_PLOT, 'PS'
TVLCT, rr, gg, bb
SET_PLOT, old_device

;TVLCT, rr, gg, bb
;if (old_device eq 'x') or (old_device eq 'X') then TVLCT, rr, gg, bb
!p = old_p


end



