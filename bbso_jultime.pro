;  Name : BBSO_jultime
;  
;  Purpose : return the Julian Day value from the BBSO data filename(TiO, IRIM, He10830)
;  
;  Calling Sequence : time = bbso_jultime(f_bbso) ;; in their directory
;  
;  Input 
;    - f_bbso : BBSO file name(array)
;    
;  Output : Julian day (double type)    

function bbso_jultime, f_bbso

if n_elements(f_bbso) eq 0 then begin
    message, 'Incorrect argument  (!ºoº)!', /cont
    message, 'Calling sequence : time = bbso_jultime(filename)', /cont
    return, -1
endif

time=dblarr(n_elements(f_bbso))
pp=strpos(f_bbso[0], 'pcosr_')
date=strmid(f_bbso, pp+6, 15)
time=anytim2jul(date)
;for i=0, n_elements(f_bbso)-1 do begin
;;  date=fxpar(headfits(f_bbso[i]), 'date-obs')
;;  time[i]=anytim2jul(date)
;endfor
if n_elements(time) eq 1 then time=time[0]
return, time
end