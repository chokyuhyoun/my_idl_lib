;+
;
; IDL batch file to run mosaics if/when needed
;
;-

PRINT, 'IRIS_MOSAIC_PIPELINE: Starting!'

IRIS_MOSAIC_CATALOG, rr, /add, daysback = 12
stop
; Set up path and filename constants
filename = 'iris_mosaic_' + TIME2FILE(/sec, RELTIME(/now)) + '.txt'
; Base path for mosaic working directories
default_path = '/sanhome/schmit/fake_mosaic'
; Base path where mosaic files are posted when processing is done
online_path = '/sanhome/schmit/fake_mosaic/'
; Base path where HTML file is staged before updating the website
html_path = '/sanhome/schmit/fake_mosaic/'
; Base path for scratch files used by this routine
scratch_path = '/sanhome/schmit/fake_mosaic/scratch'
; Email address to send notifications to
whotobug = 'boerner@lmsal.com'
mail_content = ''

; Set up path and filename variables
datetag = TIME2FILE(/date, rr[-1].date_obs)
datetai = ANYTIM2TAI(rr[-1].date_obs)
mpath = CONCAT_DIR(default_path, datetag)
opath = CONCAT_DIR(online_path, datetag)
if FILE_EXIST(mpath) then started = 1 else started = 0
if FILE_EXIST(opath) then finished = 1 else finished = 0
if ( FILE_DATE_MOD( CONCAT_DIR(html_path, 'mosaic.html') ) - datetai) gt 86400d $
	then posted = 1 else posted = 0
scriptfile = CONCAT_DIR(scratch_path, 'iris_mosaic_mail.applescript')
ofile = CONCAT_DIR(scratch_path, filename)
apple_ofile = STR_REPLACE(ofile, '/', ':')
apple_ofile = STRMID(apple_ofile, 1, STRLEN(apple_ofile))

; Depending on the status, decide what to do
case 1 of
	; Nothing new; just get out
	posted		: 	begin
	end
	; Processing done; let somebody know that the new html file needs to be posted
	finished	:	begin	
		html_file = CONCAT_DIR(opath, 'mosaic_test.html')
		cpcmd = 'cp ' + html_file + ' ' + html_path
		PRINT, cpcmd
		SPAWN, cpcmd, result, errcode
		mail_content = 'Finished ' + datetag + '; run hg pull, update, ' + $
			'commit, push in ' + html_path + ' to online the HTML file'
	end
	; Still processing; let somebody know that they should check on things
	started		:	begin
		mail_content = 'Already running ' + datetag
	end
	; A new mosaic needs to be started!
	else			:	begin
		mail_content = 'Starting ' + datetag
;		IRIS_MOSAIC_MAKER, rr[-1].date_obs, rr[-1].date_end, mpath, $
;                                   /debug, /kludge, /nodopp, /silent
                                ;removed kludge oct 27 for oct 12 onward
                IRIS_MOSAIC_MAKER, rr[-1].date_obs, rr[-1].date_end, mpath, $
                                   /debug, /nodopp, /silent               
	end
endcase

; Make an applescript file so that you can use Mac Mail app to send notification
if mail_content ne '' then begin
	;	Applescript based on example at https://gist.github.com/Moligaloo/3850710
	applescript_text = ['tell application "Mail"', $ 
		'set theSubject to "Cron update from IRIS_MOSAIC_PIPELINE" -- the subject', $
		'set theContent to "' + mail_content + '" -- the content', $
		'set theAddress to "' + whotobug + '" -- the receiver ', $
		'', $
		'set msg to make new outgoing message with properties {subject: theSubject, content: theContent, visible:true}', $
		' ', $
		'tell msg to make new to recipient at end of every to recipient with properties {address:theAddress}', $
		'', $
		'send msg', $
		'end tell', $
		'']
	numlines = N_ELEMENTS(applescript_text)
	OPENW, lun, /get_lun, scriptfile
	for i = 0, numlines - 1 do PRINTF, lun, applescript_text[i]
	FREE_LUN, lun
	SPAWN, 'osascript ' + scriptfile
endif

PRINT, 'IRIS_MOSAIC_PIPELINE: Done!'

end
