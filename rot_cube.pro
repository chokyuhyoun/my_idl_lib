function rot_cube, arr, ang, missing=missing
  if n_elements(missing) eq 0 then missing=0.
  if n_elements(ang) ne 3 then begin
    message, 'Please input 3 rotation angle
    return, -1
  endif
  sz=size(arr)
  xp=findgen(sz[1])-0.5*(sz[1]-1)
  yp=findgen(sz[2])-0.5*(sz[2]-1)
  zp=findgen(sz[3])-0.5*(sz[3]-1)
  xxp=rebin(xp, sz[1], sz[2], sz[3])
  yyp=rebin(reform(yp, 1, sz[2]), sz[1], sz[2], sz[3])
  zzp=rebin(reform(zp, 1, 1, sz[3]), sz[1], sz[2], sz[3])
  t3d, /reset, rotate=ang
  pos=!p.t[0:2, 0:2]##[[xxp[*]], [yyp[*]], [zzp[*]]]
  posx=pos[*, 0]+0.5*(sz[1]-1)
  posy=pos[*, 1]+0.5*(sz[2]-1)
  posz=pos[*, 2]+0.5*(sz[3]-1)
  new_cube=interpolate(arr, posx, posy, posz, missing=missing)
  t3d, /reset
  return, reform(new_cube, sz[1], sz[2], sz[3])
end