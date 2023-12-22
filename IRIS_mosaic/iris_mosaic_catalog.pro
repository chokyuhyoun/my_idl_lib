pro IRIS_MOSAIC_CATALOG, $
	result, $
	save = save, load = load, add = add, init = init, fix = fix, $
	opath = opath, file = file, pstop = pstop, quiet = quiet, daysback = daysback, my_t0=my_t0, nrt=nrt

;+
;
; Looks through the timeline files for instances of the full-disk mosaic queue,
; and pulls them out into a catalog structure. Seems to only go back 1 year...?
;
; KEYWORDS:
;	/init	-	Hard-coded setup for the mosaics known to have run prior to 2014
;	/fix	-	Hard-coded setup for first 2-part mosaic, which was run without
;				the specified string (Mosaic) in the description
;
;
;-

if N_ELEMENTS(load) eq 0 then load = 1	;	Load by default
if N_ELEMENTS(daysback) eq 0 then daysback = 1.5

t0 = '1-aug-2013'
t1 = RELTIME(days=0-daysback)

if not KEYWORD_SET(opath) then opath = '/irisa/data/MosaicTest/'
;if KEYWORD_SET(nrt) then opath = '/irisa/data/level1_nrt/'
if KEYWORD_SET(add) then begin
	load = 1
	save = 1
endif

; Here's the basic structure layout for the mosaic catalog
template = CREATE_STRUCT('Q_START', '2013-09-30T11:00:00', 'PID', 0, $
	'QID', 'Q31_FD_mosaic_science_30sep13', $
	'DURATION', 0., 'DATARATE', 0., 'DUNIT', 'megabits/sec', $
	'DATE_END', '', 'DATE_OBS', '', 'Q_STOP', '', $
	'DESCRIPTION', 'Full Disk Mosaic from IRIS_MOSAIC_CATALOG','OBSID','')
		
if KEYWORD_SET(init) then begin
	; Note that it doesn't automatically find the first few mosaics, 
	; run before 2014-03-06. This keyword "manually" sets them up
	if KEYWORD_SET(load) then begin
		PRINT, 'IRIS_MOSAIC_CATALOG: Do not set /init and /load! Unsetting /load...'
		load = 0
	endif
	
	t0s = ['2013-09-30T11:0', '2013-10-13T04:3', '2013-10-21T11:0', '2013-10-27T01:0'] + '0:00.000'
	t1s = ['2013-10-01T04:0', '2013-10-13T21:0', '2013-10-22T04:0', '2013-10-28T04:0'] + '0:00.000'
	numinit = N_ELEMENTS(t0s)
	initresult = REPLICATE(template, numinit)
	for i = 0, numinit - 1 do begin
		fjd = ANYTIM2JD(t0s[i])
		CALDAT, fjd.int + fjd.frac, month, day, year
		initresult[i].q_start = t0s[i]
		initresult[i].qid = 'Q31_FD_mosaic_science_' + STRING(day, form = '(i02)') + $
			STRLOWCASE(STRMID(GET_MONTH(month), 0, 3)) + STRING(year mod 100, form = '(i02)')
		initresult[i].duration = ANYTIM2TAI(t1s[i]) - ANYTIM2TAI(t0s[i])
		initresult[i].date_end = t1s[i]
		initresult[i].date_obs = t0s[i]
		initresult[i].q_stop = t1s[i]
	endfor
endif

if KEYWORD_SET(load) then begin
	; Load a previously-saved mosaic catalog
	if N_ELEMENTS(file) gt 0 then mosfile = file else begin
		files = FILE_SEARCH(CONCAT_DIR(opath, '*moscat.genx'))
		filetai = ANYTIM2TAI(FILE2TIME(STRMID(FILE_BASENAME(files), 0, 15)))
		latest = WHERE(filetai eq MAX(filetai))
		mosfile = files[latest[-1]]
	endelse
        print, mosfile
	RESTGEN, file = mosfile, result
	if KEYWORD_SET(add) then begin
		t0 = result[-1].date_end
		oresult = result
	endif
endif

if keyword_set(my_t0) then t0 = my_t0     ;;; Mod. 20171115 by ASD
print, t0, t1
wait, 3
stop

;t0 = '2022-05-07T12:31:30.000'
;t1 = '2022-05-09T03:26:36.000'
if N_ELEMENTS(result) eq 0 or KEYWORD_SET(add) then begin
	; Generate from timelines
	qs = IRIS_TIME2TIMELINE(t0, t1, /queue)
	if N_TAGS(qs) gt 0 then begin
		mospos = STRPOS(qs.description, 'osaic')
		fdmpos = STRPOS(qs.description, 'FDM')
		p1pos = STRPOS(qs.description, 'art 1')
		p2pos = STRPOS(qs.description, 'art 2')
		print, 'Mosaic position', mospos
        print, 'FDM position', fdmpos
        print, 'Part 1 position', p1pos
        print, 'Part 2 position', p2pos
		; only include 1-part or first-part queues
		imos = WHERE(mospos ge 0 and p2pos lt 0, nmos)
		if nmos eq 0 then imos = WHERE(fdmpos ge 0 and p2pos lt 0, nmos)
		if nmos gt 0 then result = qs[imos] else result = 0
		; Now go through and fix up the end times for 2-part mosaics
		i2mos = WHERE(mospos ge 0 and p2pos ge 0, n2mos)
        print, 'imos, nmos, i2mos, n2mos', imos, nmos, i2mos, n2mos
        ;stop
		if n2mos gt 0 then begin
            result = qs[i2mos]
			i1mos = WHERE(mospos ge 0 and p1pos ge 0, n1mos)
			if n1mos ne n2mos then STOP	;	Assume a 1-to-1 correspondence
			for i = 0, n2mos - 1 do begin
				if i1mos ne -1 then begin
                   mosid = WHERE(result.date_obs eq qs[i1mos[i]].date_obs)
                endif else begin
                   mosid = WHERE(result.date_obs eq qs[i2mos[i]].date_obs)
                endelse 
				result[mosid].date_end = qs[i2mos[i]].date_end
				result[mosid].q_stop = qs[i2mos[i]].date_end
				result[mosid].duration = ANYTIM2TAI(result[mosid].date_obs) - $
										ANYTIM2TAI(result[mosid].date_end)
				result[mosid].description = result[mosid].description + $
					' (Part 2 appended)'
				print, i,  result[mosid].date_end
			endfor
		endif
	endif else result = 0
endif
stop
;result.q_start = qs[0].q_start
;result.date_obs = qs[0].date_obs

if keyword_set(my_t0) then stop

; Hard-coded entry for the 2-part mosaic on 2015-03-22, which didn't have the 
; word mosaic in the description (and was run in 2 parts)
if KEYWORD_SET(fix) then begin
	fixresult = template
	t0 = '2015-03-22T04:40:00.000'
	t1 = '2015-03-22T21:00:00.000'
    t0 = '2022-09-25T11:58:50.000'
    t1 = '2022-09-27T02:53:56.000'
	fixresult.q_start = t0
	fixresult.qid = 'Q31_EIS_FD_scan'
	fixresult.duration = ANYTIM2TAI(t1) - ANYTIM2TAI(t0)
	fixresult.date_end = t1
	fixresult.date_obs = t0
	fixresult.q_stop = t1
	if N_TAGS(result) eq 0 then result = fixresult else begin
		result = [result, fixresult]
		rtimes = ANYTIM2TAI(result.date_obs)
		result = result[SORT(rtimes)]
	endelse
endif

if KEYWORD_SET(pstop) then STOP

if KEYWORD_SET(add) then begin
	if N_TAGS(result) gt 0 then begin
                ; Useful commands to incorporate special calibration mosaic (see Ryan email at 20180319) 
                ; aux = create_struct(result, 'OBSID', '3882200195') ;;; ASD 20180319
                ; result = aux 
		result = [oresult, result]
	endif else begin
		result = oresult
		if KEYWORD_SET(save) then begin
			PRINT, 'IRIS_MOSAIC_CATALOG: Nothing to add, not saving...'
			save = 0
		endif
	endelse
endif

if KEYWORD_SET(init) then begin
	if N_TAGS(result) gt 0 then result = [initresult, result] else result = initresult
endif

nmos = N_ELEMENTS(result)
if nmos lt 1 then begin
	PRINT, 'IRIS_MOSAIC_CATALOG: No Mosaics!'
	RETURN
endif

if not KEYWORD_SET(quiet) then begin
	PRINT, ' ', 'DATE_OBS', 'DATE_END', 'Description', form = '(a5,2a25,a45)'
	for i = 0, nmos - 1 do PRINT, i, result[i].date_obs, result[i].date_end, $
		result[i].description, form = '(i5,2a25,a45)'
endif

if KEYWORD_SET(save) then begin
	mosfile = TIME2FILE(/sec, RELTIME(/now)) + '_moscat.genx'
        print, 'Saving IRIS mosaic catalog at...', mosfile
	SAVEGEN, file = CONCAT_DIR(opath, mosfile), result
endif

if KEYWORD_SET(pstop) then STOP

end
