pro ng_drange, obj, drange
  if n_elements(drange) eq 1 then drange=[-1d, 1d]*drange
  obj.min=drange[0]
  obj.max=drange[1]
end