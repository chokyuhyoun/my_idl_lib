function intersect_, x, y
  if n_elements(x) eq 0 or n_elements(y) eq 0 then return, !null
  xx = x[UNIQ(x, SORT(x))]
  yy = y[UNIQ(y, SORT(y))]
  z = [xx, yy]
  zz = z[sort(z)]
  d = zz - shift(zz, 1)
  w = where(d eq 0, count, /null)
;  stop
  if count eq 0 then return, !null
  return, zz[w]
end