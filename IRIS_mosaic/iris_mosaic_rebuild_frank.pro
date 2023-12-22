pro IRIS_MOSAIC_REBUILD_FRANK, home_dir, $
	waves = waves, silent = silent, pstop = pstop

;+
;
; INPUT:
;	home_dir	-	Full path to the top-level directory for the IRIS Mosaic.
;	
;		This routine will put a file called YYYYMMDD_IRIS_FrankenMaps_SDO.genx
; 		in the home_dir, giving a series of SDO maps that match the IRIS mosaics
; 		in time (more or less)
;
; KEYWORDS:
;	waves		-	(INPUT) set to an array of AIA wavelengths to include
;					Defaults to [1600, 304, 193, 171]
;	/silent		-	(SWITCH) set to avoid plotting sub-images along the way
;
;
;-

if N_ELEMENTS(waves) eq 0 then waves = [1600, 304, 193, 171]
nwaves = N_ELEMENTS(waves)

ff = FILE_SEARCH( CONCAT_DIR(home_dir, 'SDO/maps/Point*.genx'), count =fc)
datestr = FILE_BASENAME(home_dir)
ofile = CONCAT_DIR(home_dir, datestr + '_IRIS_FrankenMaps_SDO.genx')

tags = ['hmi', 'aia_' + STRING(waves, form = '(i04)')]
idd = ['SDO/HMI LoS Magnetogram', 'SDO/AIA ' + STRTRIM(waves, 2) + STRING(197B)]

box_x = FLTARR(fc, 2)
box_y = FLTARR(fc, 2)

if not KEYWORD_SET(silent) then begin
	for i = 0, nwaves do WDEF, i+10, 800, 800, title = tags[i]
	yrange = [-1000, 1000]
	xrange = [-1000, 1000]
	immins = [-128., FLTARR(nwaves)]
	immaxs = [128, FLTARR(nwaves)+16384.]	
endif

if KEYWORD_SET(pstop) then STOP
; Loop through each pointing and assign data to all the FrankenMaps
for jj=0, fc-1 do begin

	RESTGEN, file = ff[jj], str = mapstr
	nmaptags = N_TAGS(mapstr)
	if nmaptags gt 4 then begin
	
		; Initialize the FrankenMaps on the first pointing
		if N_ELEMENTS(map_template) eq 0 then begin
			map_template = CREATE_STRUCT('DATA', FLTARR(4096, 4096), 'XC', 0., 'YC', 0.)
			sub_template = mapstr.(4)
			sub_tags = TAG_NAMES(sub_template)
			for i = 0, N_TAGS(sub_template) - 1 do begin
				if TOTAL(sub_tags[i] eq ['DATA', 'XC', 'YC']) eq 0 then begin
					map_template = CREATE_STRUCT(map_template, sub_tags[i], sub_template.(i))
				endif
			endfor
			magx = map_template.xc + (FINDGEN(4096) - 2048.) * map_template.dx
			magy = map_template.yc + (FINDGEN(4096) - 2048.) * map_template.dy
			thistag = tags[0]
			thismap = map_template
			thismap.id = idd[0]
			allmaps = CREATE_STRUCT(thistag, thismap)
			for ii = 1, nwaves do begin
				thistag = tags[ii]
				thismap = map_template
				thismap.id = idd[ii]
				allmaps = CREATE_STRUCT(allmaps, thistag, thismap)
			endfor
		endif

		maptags = TAG_NAMES(mapstr)
		mmx = MINMAX(mapstr.solarx)
		mmy = MINMAX(mapstr.solary)
		dsize = SIZE(mapstr.(4).data)
		nnx = dsize[1]
		nny = dsize[2]
		box_x[jj,*] = mmx
		box_y[jj,*] = mmy
	
		bestx = WHERE(magx ge mmx[0] and magx le mmx[1])
		besty = WHERE(magy ge mmy[0] and magy le mmy[1])
		for ii = 0, nwaves do begin
			tagind = WHERE(maptags eq STRUPCASE(tags[ii]), hastag)
			if hastag gt 0 then begin
				thissub = mapstr.(tagind)
				allmaps.(ii).data[bestx[0]:bestx[0]+nnx-1, besty[0]:besty[0]+nny-1] = thissub.data[*,*]
			endif else begin
				PRINT, 'IRIS_MOSAIC_REBUILD_FRANK: No match...?', ii, jj
			endelse
			if not KEYWORD_SET(silent) then begin
				WSET, ii + 10
				if ii eq 0 then wave = 1 else wave = waves[ii-1]
				AIA_LCT, wave = wave, /load
				PLOT_IMAGE, AIA_INTSCALE(/byte, wave = wave, allmaps.(ii).data, /exp), $
					origin = [MIN(magx), MIN(magy)], scale = [map_template.dx, map_template.dy], $
					xtitle = map_template.xunits, ytitle = map_template.yunits, chars = 1.2, $
					xrange = xrange, yrange = yrange, min = 0, max = 255, $
					position = [0.1, 0.1, 0.85, 0.85], bottom = 1, top = 254
				if tags[ii] eq 'hmi' then begin
					title = 'Line-Of-Sight Magnetic Field [Gauss]'
					scalevect = INDGEN(32768l) - 16384l
				endif else begin
					scalevect = INDGEN(16384)
					title = 'Count rate [DN/s]'
				endelse
				scaler = AIA_INTSCALE(/byte, wave = wave, scalevect, /exp)
				ticks = INTERPOL(scalevect, scaler, INDGEN(6)/5. * 254)				
				COLORBAR, /horiz, bottom = 1, top = 254, pos = [0.25, 0.91, 0.70, 0.94], $
					div = 5, ticknames = STRING(ticks, form = '(i5)'), title = title
			endif
		endfor
	endif
		
endfor

; Now grab the plots and save them as PNGs (if you made them)
if not KEYWORD_SET(silent) then for ii = 0, nwaves do begin
	WSET, ii + 10
	thisimg = TVRD(/true)
	WRITE_PNG, CONCAT_DIR(home_dir, 'figs/' + tags[ii] + '.png'), thisimg
endfor
; stop
SAVEGEN, file = ofile, str = allmaps

end
