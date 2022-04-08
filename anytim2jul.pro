;+ anytim2jul
;
; :Description:
;    Converts (almost) any time format to julian day via anytim2utc function
;
; :Params:
;    time : any time format
;
; :Author: K. Cho (SNU)
;-

function anytim2jul, time
    utc=anytim2utc(time)
    return, utc.mjd+2400000.5d0+utc.time*1d-3/86400d0
end


    