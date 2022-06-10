pro setdata_hi_res, obj, img, x, y
  case n_params() of
    2 : begin
      dx = 1
      dy = 1
      x = findgen(sz[1])
      y = findgen(sz[2])
    end
    3 : begin
      dx = x[1]-x[0]
      dy = 1
      y = findgen(sz[2])
    end
    4 : begin
      dx = x[1]-x[0]
      dy = y[1]-y[0]
    end
    else : message, 'Check the number of arguments', /continue
  endcase
  x1 = x-0.5*dx
  y1 = y-0.5*dy
  img1 = img
  hi_res, img1, x1, y1, obj.xr, obj.yr
  obj.setdata, img1, x1, y1
end
