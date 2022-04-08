pro cube_tv, cube, mm, wait=wait
  if n_elements(wait) eq 0 then wait=0.05
;  window, /free, xs=(size(cube))[1], ys=(size(cube))[2]
  if (size(cube))[0] eq 3 then begin
    for i=0, (size(cube))[3]-1 do begin
      case n_params() of
         1 : tvscl, cube[*, *, i]
         2 : tv, bytscl(cube[*, *, i], mm[0], mm[1]) 
      endcase
      wait, wait
    endfor
  endif else tvscl, cube
;  stop
end