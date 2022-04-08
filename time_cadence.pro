  ;+ time_cadence
  ; :Description:
  ;    calculate time cadence
  ;
  ; :Params:
  ;    time : julian time array of data
  ;
  ;
  ;
  ; :Author: chokh
  ;- 2016. 9. first coded

function time_cadence, time

dum1=[time, 0]*86400d
dum2=[0, time]*86400d
cadence=(dum1-dum2)[1:-2]
return, cadence
end