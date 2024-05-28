pro for_percent, run_var, max_value, interval=interval
  if n_elements(interval) eq 0 then interval = 10. ; in %
  arr = findgen(max_value)
  init = uniq(floor(arr/max_value*interval))
  init = [0, init+1]
  dum = where(run_var eq init, count)
  if count then begin
    per = string(floor(run_var/max_value*interval)*interval, f='(i3)')+' %'
    s = execute("print, string(run_var, f='(i"+string(floor(alog10(max_value)), f='(i0)')+")')" + $
      " + ' / ' + string(max_value, f='(i0)') + '   ' + per + '   ' + systime()")
  endif
end    