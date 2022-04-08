;+
; :Description:
;    tick format function for julian date 
;    ex) plot, time, value, xtickformat='tick_time'
;  
; :Params:
;    axis
;    index
;    value
;
;
;
; :Author: chokh
;-
function tick_time, yr=yr, mon=mon, day=day, sec=sec, _extra=extra
  y=(keyword_set(yr)) ? '%Y.' : '' 
  m=(keyword_set(mon)) ? '%N.' : ''
  d=(keyword_set(day)) ? '%D. ' : ''
  s=(keyword_set(sec)) ? '%S' : ''
  format=y+m+d+'%H:%I'+s
  return, label_date(date_format=format, $
                      /round, _extra=extra)
end