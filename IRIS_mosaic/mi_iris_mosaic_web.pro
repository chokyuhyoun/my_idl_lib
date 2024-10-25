pro MI_IRIS_MOSAIC_WEB, dir, $
	windaes = windaes, pstop = pstop, $
	nojpg = nojpg, nosdofits = nosdofits, nosdojpgs = nosdojpgs, $
	nocopy = nocopy, nohtml = nohtml, $
	add_kludge = add_kludge, nodoppler = nodoppler, $
	gamma_val = gamma_val, pattern_year_web=pattern_year_web, $
	only_html = only_html

	
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
sizes = [1000, 64] ; Sizes of the jpgs  
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

if KEYWORD_SET(only_html) eq 0 then begin
; Generate JPEGs and thumbnails for each channel
if not KEYWORD_SET(nojpg) then for i = 0, numwin - 1 do begin
	fitsfile = CONCAT_DIR(dir, 'IRISMosaic_' + datestr + '_' + windaes[i] + '.fits')
	print, fitsfile 
	if not FILE_EXIST(fitsfile) then begin
		if FILE_EXIST(fitsfile + '.gz') then begin
			PRINT, 'IRIS_MOSAIC_WEB: gunzipping ' + fitsfile
			SPAWN, 'gunzip ' + fitsfile + '.gz', result, errcode
			MREADFITS, fitsfile, hdr, dat
		endif else begin
			PRINT, 'IRIS_MOSAIC_WEB: File'+fitsfile+'  missing!'
		endelse
	endif else begin
		MREADFITS, fitsfile, hdr, dat
	endelse
    ;stop
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
endif 

year4web_txt = '????'
year4web = -1
if KEYWORD_SET(pattern_year_web) then begin
        year4web = pattern_year_web
	year4web_txt = strcompress(year4web, /remove)
	year4web_prev = strcompress(year4web-1, /remove)
	year4web_next = strcompress(year4web+1, /remove)
endif 

; Write some HTML to incorporate the results
if not KEYWORD_SET(nohtml) then begin
	; Set up some constants defining the geometry of the table
	;donedates = FILE_SEARCH(CONCAT_DIR(online_base, '20??????'))	;	Dates with directories online
	donedates = FILE_SEARCH(CONCAT_DIR(online_base, year4web_txt+'????'))	;	Dates with directories online
	numdate = N_ELEMENTS(donedates)			;	Number of dates in the table
	tabwidth = 950			;	Width of the table in pixels
	rowheight = 52			;	Height of the rows in the table
	thumbsize = 50			;	Pixel size of the thumbnail images
	tabpad = 3				;	Padding around the table border in pixels
	datewidth = 150			;	Width of the first (date) column, in pixels
	linesep = 20			;	Pixels between image pairs from different lines
	dopsep = 7				;	Pixels between the doppler and the line-center image
	if year4web lt 2013 then begin
	        tabheight = (numdate -1) * (rowheight + 20) + 50	;	Height of the table in pixels
        endif else begin
	        tabheight = (numdate) * (rowheight + 20) + 50	;	Height of the table in pixels
        endelse	
	print, donedates, numdate
	titleheight = rowheight - 10

	if KEYWORD_SET(nodoppler) then begin
		rowheight = 83
		thumbsize = 81
		dopsep = 25
		linesep = -99
		;tabheight = tabheight + (numdate * 31.)
		;tabheight = tabheight + (numdate * 33.)
		if year4web eq -1  then begin
			tabheight = (numdate * (rowheight+2+2))
		        tabheight = tabheight + 45 + 10 + 1  ; height_label_index  
		        tabheight = tabheight + 45 + 10 + 1 + 45 ; height_row for all in 1 year + 10 padding bottom + 1 padding top
                endif else begin
		        tabheight = (numdate * (rowheight+2+2))     ; num_mosaicx x (height_mosaic_row + padding top + padding bottom)
                        tabheight = tabheight + 45 + 1 + 1  ; height_label_date_spectral_range + padding top + padding bottom
		        tabheight = tabheight + 45 + 10 + 1  ; height_label_index  + padding top + padding bottom  
		        tabheight = tabheight + 45 + 1 + 1  ; height_row for previous, year, next + padding top + padding bottom
		        tabheight = tabheight + 45 + 1 ; height_row for all in 1 year + 10 padding bottom + 1 padding top
		endelse 
		tabwidth = 850
		titleheight = 45
	endif
	
	html_start = '<!-- This is the start of the content for the mosaic page -->'
	html_autostart = '<!-- This is the start of the auto-content for the mosaic page -->'
	html_autoend = '<!-- This is the end of the auto-content for the mosaic page -->'
	html_end = '<!-- This is the end of the content for the mosaic page -->'
;	html_leadin = '<p style="width:' + STRTRIM(tabwidth, 2) + 'px"> This is the web page for IRIS mosaics. FITS files can be accessed by clicking on the date links in the table below. Instructions for reading and interpreting the FITS files follow the table.</p>'
	html_tabstart = '<div style="width:' + STRTRIM(tabwidth, 2) + 'px; height:' + STRTRIM(tabheight, 2) + 'px; border:1px solid red; padding:' + STRTRIM(tabpad, 2) + 'px;">'
	;;; Labels for mosaic_YYYY.html
        ;html_index = '<div style="width:840px; height:45px; padding:1px 25px 1px 1px; border:0px solid blue; float:left; line-height:83px; display:table-cell"><center>Index by year</center></div>'
        html_index = '<div style="width:840px; height:45px; padding:10px 1px 1px 15px; border:0px solid blue; line-height:30px; font-size:20px;  display:table-cell"><center><a href="mosaic_index.html">Index by year</a></center></div>'
        if year4web ge 2013 then begin
		html_allin1 = '<div style="width:840px; height:45px; padding:20px 1px 1px 10px; border:0px solid blue; float:left; line-height:33px; font-size:20px; display:table-cell"><center><a href="mosaic_allin1.html">All available IRIS Mosaics in 1 page</a></center></div>'
		html_previous = '<div style="width:150px; height:45px; padding:1px 25px 1px 1px; border:0px solid blue; float:left; line-height:33px;  font-size:20px; display:table-cell"><center><a href="mosaic_'+year4web_prev+'.html"><< Previous</a></center></div>'
		if year4web eq 2013 then $& 
			html_previous = '<div style="width:150px; height:45px; padding:1px 25px 1px 1px; border:0px solid blue; float:left; line-height:33px;  font-size:20px; display:table-cell"><center>           </center></div>'
		html_year = '<div style="width:505px; height:45px; padding:1px 50px 1px 1px; border:0px solid blue; float:left; line-height:33px;  font-size:40px; display:table-cell"><center>'+year4web_txt+'</center></div>'
		;html_next = '<div style="width:81px; height:45px; padding:1px 25px 1px 1px; border:0px solid blue; float:left; line-height:33px; display:table-cell"><right><a href="http://www.lmsal.com/solarsoft/irisa/data/level2_compressed/2013/09/30/20130930Mosaic/">Next >></a></center></center></div>'
		html_next = '<div style="width:91px; height:45px; padding:1px 5px 1px 1px; border:0px solid blue; float:left; line-height:33px;  font-size:20px; display:table-cell"><right><a href="mosaic_'+year4web_next+'.html">Next >></a></center></div>'
		spawn, 'date +%Y', current_year
		if year4web eq current_year then $& 
	                html_next = '<div style="width:91px; height:45px; padding:1px 5px 1px 1px; border:0px solid blue; float:left; line-height:33px;  font-size:20px; display:table-cell"><right>       </center></div>'
	endif
	;;; Labels for mosaic_YYYY.html
	html_rowend = '</div>'
	html_rowclear = '<p style="clear: both;">'
	;;; Mod. Migration to AWS - 20200113 (ASD)
	    html_base = 'http://www.lmsal.com/solarsoft/irisa/data/mosaic/' 
	    html_base_compressed = 'http://www.lmsal.com/solarsoft/irisa/data/level2_compressed/'
	;;; Mod. Migration to AWS - 20200113 (ASD)
	coltitles = [['Date', 'MgIIh','MgIIk'],['Si IV 1393','Si IV 1403','C II 1334', 'C II 1335'] + ' A']	;	+STRING(197B)
	; Open the current online file and read to the section you want to be at
	;;; pubfile = CONCAT_DIR(online_base, 'mosaic.html')
	pubfile_all = CONCAT_DIR('/sanhome1/asainz/IRIS_mosaic', 'mosaic_all.html')
	htmlfile = CONCAT_DIR('/sanhome1/asainz/IRIS_mosaic', 'mosaic_allin1.html')
	template_year= CONCAT_DIR('/sanhome1/asainz/IRIS_mosaic', 'template_mosaic_year.html')
	;;; htmlfile = CONCAT_DIR(online_base, 'mosaic_test.html')
	if year4web_txt eq '????' then begin
		print, online_base
		;;; OPENR, olun, /get, pubfile
		OPENR, olun, /get, pubfile_all
		thisline = ' '
		OPENW, lun, /get, htmlfile
		while STRTRIM(thisline, 2) ne html_autostart do begin
			READF, olun, thisline
			PRINTF, lun, thisline
		endwhile
		if KEYWORD_SET(pstop) then STOP
        endif else begin
	        pubfile_year  = CONCAT_DIR('/sanhome1/asainz/IRIS_mosaic', 'mosaic_'+year4web_txt+'.html')
		print, online_base
		;;; OPENR, olun, /get, pubfile
		OPENR, olun, /get, template_year 
		thisline = ' '
		OPENW, lun, /get, pubfile_year
		while STRTRIM(thisline, 2) ne html_autostart do begin
			READF, olun, thisline
			PRINTF, lun, thisline
		endwhile
		if KEYWORD_SET(pstop) then STOP
        endelse 

	PRINTF, lun
	PRINTF, lun, STRING('', form = '(a12)') + html_tabstart
	if year4web eq -1 then PRINTF, lun, STRING('', form = '(a12)') + html_index
	;;; Labels for mosaic_YYYY.html
	if year4web ge 2013 then begin
		thisheight = rowheight
		;html_rowstart = '<div style="width:' + STRTRIM(tabwidth - 10,2) + 'px; height:' + STRTRIM(thisheight, 2) + 'px; border:0px; padding:2px;">'
		;PRINTF, lun, STRING('', form = '(a12)') + html_rowstart
	        PRINTF, lun, STRING('', form = '(a12)') + html_index
		;PRINTF, lun, STRING('', form = '(a12)') + html_rowend
		;PRINTF, lun, STRING('', form = '(a12)') + html_rowclear

		;PRINTF, lun, STRING('', form = '(a12)') + html_rowstart
		PRINTF, lun, STRING('', form = '(a12)') + html_previous
		PRINTF, lun, STRING('', form = '(a12)') + html_year
		PRINTF, lun, STRING('', form = '(a12)') + html_next
		;PRINTF, lun, STRING('', form = '(a12)') + html_rowend
		;PRINTF, lun, STRING('', form = '(a12)') + html_rowclear
        endif 
	;;; Labels for mosaic_YYYY.html
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
						; thumb_file = jpg_base + 'core_' + STRTRIM(sizes[1], 2) + '.jpg' ;;; 20211029: Modified by ASD after Bart's request: 64->1000
						thumb_file = jpg_base + 'core_' + STRTRIM(sizes[0], 2) + '.jpg'
						thiscontent = '<a href="' + jpg_file + '"><img style = "width:' + STRTRIM(thumbsize,2) + 'px; height:' + STRTRIM(thumbsize,2) + 'px" src="' + thumb_file + '"></a>'
					endif else begin
						thiscontent = ''
					endelse
				end
			endcase
			thissep = dopsep
			;print, thissep,  STRTRIM(thissep, 2), thiscontent 
			padding_right = STRTRIM(thissep, 2)
			padding_bottom = '1'
			width_cell = STRTRIM(thiswidth, 2) 
			case 1 of 
			        thiscontent eq 'Date': padding_bottom = '10'
			        thiscontent eq 'MgIIh': begin
					    padding_right = '25' 
		                       	    padding_bottom = '10'
					    width_cell = '81'
				        end     
			        thiscontent eq 'MgIIk': begin
					    padding_right = '20' 
		                       	    padding_bottom = '10'
					    width_cell = '81'
				        end     
				thiscontent eq 'Si IV 1393 A' or thiscontent eq 'Si IV 1403 A' or thiscontent eq 'C II 1334 A' or thiscontent eq 'C II 1335 A': begin
					    ;padding_right = '15' ;;; OK for me
			                    ;width_cell = '91'   ;;; OK for me
					    padding_right = '10' ;;; OK for public
		                       	    padding_bottom = '10'
			                    width_cell = '95'   ;;; OK for Public
				        end
				else:        
                        endcase 
			print, padding_right
			;html_thiscell = '<div style="width:' + STRTRIM(thiswidth, 2) + 'px; height:' + STRTRIM(thisheight, 2) + 'px; padding:1px ' + STRTRIM(thissep, 2) + 'px 1px 1px; border:0px solid blue; float:left; line-height:' + STRTRIM(rowheight, 2) + 'px; display:table-cell"><center>' + thiscontent + '</center></div>'
			html_thiscell = '<div style="width:' + width_cell + 'px; height:' + STRTRIM(thisheight, 2) + 'px; padding:1px ' + padding_right + 'px '+padding_bottom+'px  1px; border:0px solid blue; float:left; line-height:' + STRTRIM(rowheight, 2) + 'px; display:table-cell"><center>' + thiscontent + '</center></div>'
			PRINTF, lun, STRING('', form = '(a16)') + html_thiscell
			; Loop through line center and doppler for each window
			if (i ne 0) and (j ne 0) and (not KEYWORD_SET(nodoppler)) then begin
				thissep = linesep
				if FILE_EXIST(thisfits) then begin
					jpg_file = jpg_base + 'doppler_1000.jpg'
					; thumb_file = jpg_base + 'doppler_' + STRTRIM(sizes[1], 2) + '.jpg' ;;; 20211029: Modified by ASD after Bart's request: 64->1000
					thumb_file = jpg_base + 'doppler_' + STRTRIM(sizes[0], 2) + '.jpg'
					thiscontent = '<a href="' + jpg_file + '"><img style = "width:' + STRTRIM(thumbsize,2) + 'px; height:' + STRTRIM(thumbsize,2) + 'px" src="' + thumb_file + '"></a>'
				endif else begin
					thiscontent = ''
				endelse
				html_thiscell = '<div style="width:' + STRTRIM(thiswidth, 2) + 'px; height:' + STRTRIM(thisheight, 2) + 'px; padding:1px ' + STRTRIM(thissep, 2) + 'px 1px 1px; border:0px solid blue; float:left; line-height:' + STRTRIM(rowheight, 2) + 'px; display:table-cell"><center>' + thiscontent + '</center></div>'
				PRINTF, lun, STRING('', form = '(a16)') + html_thiscell
			endif
		endfor	
		PRINTF, lun, STRING('', form = '(a14)') + html_rowend
		;PRINTF, lun, STRING('', form = '(a14)') + html_rowclear
		PRINTF, lun
	endfor
	if year4web ge 2013 then begin
		PRINTF, lun, STRING('', form = '(a12)') + html_allin1
        endif else begin
	        PRINTF, lun, STRING('', form = '(a12)') + html_index
	endelse 
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



