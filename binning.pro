function binning, data, fac
  sz = size(data)
  if (sz[1] mod fac) ne 0 or (sz[2] mod fac) ne 0 then begin
    message, 'Ratio of factor and data size should be integer!'
    return, 0 
  endif
  fszx = float(sz[1])/fac
  fszy = float(sz[2])/fac
  data1 = float(data)
  data1 = total(temporary(data1), 1, /cum)
  data1 = temporary(data1[(indgen(fszx)+1)*fac-1, *])
  minusx = shift(data1, [1, 0])
  minusx[0, *] = 0.
  data1 = temporary(data1)-minusx
  data1 = total(temporary(data1), 2, /cum)
  data1 = temporary(data1[*, (indgen(fszy)+1)*fac-1])
  minusy = shift(data1, [0, 1])
  minusy[*, 0] = 0. 
  data1 = temporary(data1)-minusy
  return, data1
end