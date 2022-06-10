pro hi_res, img1, x1, y1, xr, yr, resol=resol
  if n_elements(resol) eq 0 then resol=1000.
  dx = x1[1] - x1[0]
  dy = y1[1] - y1[0]
  xind0 = max(where((x1-xr[0]) le 0))
  xind1 = min(where((x1-xr[1]) ge 0))
  x11 = x1[xind0:xind1]
  yind0 = max(where((y1-yr[0]) le 0))
  yind1 = min(where((y1-yr[1]) ge 0))
  y11 = y1[yind0:yind1]
  hi_res = ceil(resol/n_elements(x11))
  x1 = findgen(n_elements(x11)*hi_res)*dx/hi_res + x11[0]
  y1 = findgen(n_elements(y11)*hi_res)*dy/hi_res + y11[0]
  img1 = rebin(img1[xind0:xind1, yind0:yind1], n_elements(x1), n_elements(y1), /sample)
end