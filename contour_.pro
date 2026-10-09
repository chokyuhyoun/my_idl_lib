function contour_, img, x0, y0, _extra=extra

  if n_elements(img) eq 0 then return, image(/test)
  
  img1 = reform(img)
  sz = size(img1)
  case n_params() of
    1 : begin
      if size(img1, /type) eq 8 then begin
        dx = img1.dx
        dy = img1.dy
        nx = (size(img1.data))[1]
        ny = (size(img1.data))[2]
        x = (findgen(nx) - 0.5*(nx - 1))*dx + img1.xc
        y = (findgen(ny) - 0.5*(ny - 1))*dy + img1.yc
        img1 = img1.data
      endif else begin
        dx = 1.
        dy = 1.
        x = findgen(sz[1])
        y = findgen(sz[2])
      endelse
    end
    2 : begin
      dx = x[1]-x[0]
      dy = 1
      x = x0
      y = findgen(sz[2])
    end
    3 : begin
      x = (x0 eq !null) ? findgen(sz[1]) : x0
      y = (y0 eq !null) ? findgen(sz[2]) : y0
      if ((size(x))[0] eq 1) and ((size(y))[0] eq 1) then begin
        dx = x[1]-x[0]
        dy = y[1]-y[0]
      endif
      if ((size(x))[0] eq 2) and ((size(y))[0] eq 2) then begin
        dx = mean(x[1:*, *] - x[0:-2, *])
        dy = mean(y[*, 1:*] - y[*, 0:-2])
      endif
    end
    else : message, 'Check the number of arguments', /continue
  endcase
  
  x1 = x+0.5*dx
  y1 = y+0.5*dy

  xr = (n_elements(xr) eq 0) ? minmax(x1)+[0, dx] : xr
  yr = (n_elements(yr) eq 0) ? minmax(y1)+[0, dy] : yr
  if n_elements(over) ne 0 then begin
    xr = over.xr
    yr = over.yr
  endif
  
  cont = contour(img1, x1, y1, over=over, _extra=extra)
;  stop
  return, cont
end