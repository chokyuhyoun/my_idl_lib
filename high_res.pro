pro high_res, img1, x1, y1, xr, yr, resol=resol
  img0 = img1 & x0 = x1 & y0 = y1
  if n_elements(resol) eq 0 then resol=4. else resol=ceil(resol)
  dx = x1[1] - x1[0]
  dy = y1[1] - y1[0]
  xind = where((x1-xr[0]) le 0, count)
  xind0 = (count eq 0) ? 0 : max(xind)  
  xind = where((x1-xr[1]) ge 0, count)
  xind1 = (count eq 0) ? n_elements(x1)-1 : min(xind)
  x11 = x1[xind0:xind1]  

  yind = where((y1-yr[0]) le 0, count)
  yind0 = (count eq 0) ? 0 : max(yind)
  yind = where((y1-yr[1]) ge 0, count)
  yind1 = (count eq 0) ? n_elements(y1)-1 : min(yind)
  y11 = y1[yind0:yind1]
  
  x1 = findgen(n_elements(x11)*resol)*dx/resol + x11[0]
  y1 = findgen(n_elements(y11)*resol)*dy/resol + y11[0]
  img1 = rebin(img1[xind0:xind1, yind0:yind1], n_elements(x1), n_elements(y1), /sample)
;  stop
end