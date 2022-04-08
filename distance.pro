function distance, x1, y1, x2, y2 
   if n_elements(x1) eq 0 or $
      n_elements(y1) eq 0 or $
      n_elements(x2) eq 0 or $
      n_elements(y1) eq 0 then begin
      message, 'Incorrect argument. (!틃?!', /cont
      message, 'Argument : d=distance(x1, y1, x2, y2)', /cont
      return, !values.f_nan
   endif else begin   
      return, sqrt((x2-x1)^2.+(y2-y1)^2.)
   endelse
end         