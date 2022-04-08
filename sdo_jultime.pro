;  Name : sdo_jultime
;  
;  Purpose : return the Julian Day value from the SDO data filename
;  
;  Calling Sequence : time = sdo_jultime(f_sdo)
;  
;  Input 
;    - f_sdo : SDO file name(array)
;    
;  Output : Julian day    

function sdo_jultime, f_sdo

if n_elements(f_sdo) eq 0 then begin
    message, 'Incorrect argument  (!ºoº)!', /cont
    message, 'Calling sequence : time = sdo_jultime(filename)', /cont
    return, -1
endif

time=dblarr(n_elements(f_sdo))
for i=0, n_elements(f_sdo)-1 do begin
    h=headfits(f_sdo[i])
    time[i]=utc2jul(fxpar(h, 'DATE-OBS'))
endfor

;if strmatch(f_sdo[0], '*hmi*') eq 0 then begin    
;; SDO AIA data
;    position=strpos(f_sdo[0], 'T', /reverse_search)
;    yr=strmid(f_sdo, position-10, 4)
;    mon=strmid(f_sdo, position-5, 2)
;    dat=strmid(f_sdo, position-2, 2)
;    hr=strmid(f_sdo, position+1, 2)
;    min=strmid(f_sdo, position+4, 2)
;    sec=strmid(f_sdo, position+7, 2)
;endif else begin
;; SDO HMI data
;    position=strpos(f_sdo[0], 'TAI', /reverse_search)
;    yr=strmid(f_sdo, position-20, 4)
;    mon=strmid(f_sdo, position-15, 2)
;    dat=strmid(f_sdo, position-12, 2)
;    hr=strmid(f_sdo, position-9, 2)
;    min=strmid(f_sdo, position-6, 2)
;    sec=strmid(f_sdo, position-3, 2)        
;endelse
;time=julday(mon, dat, yr, hr, min, sec)
return, time
end