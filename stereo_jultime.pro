;  Name : stereo_jultime
;  
;  Purpose : return the Julian Day value from the STEREO data filename
;  
;  Calling Sequence : time = stereo_jultime(f_stereo)
;  
;  Input 
;    - f_sdo : stereo file name(array)
;    
;  Output : Julian day    

function stereo_jultime, f_stereo, time

if n_elements(f_stereo) eq 0 then begin
    message, 'Incorrect argument  (!ºoº)!', /cont
    message, 'Calling sequence : time = stereo_jultime(filename)', /cont
    return, -1
endif
   
;    position=strpos(f_stereo[0], 'T', /reverse_search)
    yr=strmid(f_stereo, 0, 4)
    mon=strmid(f_stereo, 4, 2)
    dat=strmid(f_stereo, 6, 2)
    hr=strmid(f_stereo, 9, 2)
    min=strmid(f_stereo, 11, 2)
    sec=strmid(f_stereo, 13, 2)

time=julday(mon, dat, yr, hr, min, sec)
return, time
end