function arr_eq, arr, value, diff=diff
  match=dblarr(n_elements(value))
  for i=0l, n_elements(value)-1 do begin
    dum=abs(arr-value[i])
    match[i]=(where(dum eq min(dum), /l64))[0]
  endfor
  if keyword_set(diff) then diff=value-arr[match]
  if n_elements(value) eq 1 then match=match[0]
  return, match
end