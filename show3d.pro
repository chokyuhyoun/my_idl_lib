function volume_explorer_move, window, $
  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods

  ;   help, window, isascii, character, keyvalue, x, y, press, release
  IF release THEN RETURN, 1
  window.refresh, /disable
  k = window.uvalue
  sz = size(*k.vol)
  fmt = '(i0)'
  move = (keymods eq 1) ? 50 : ((keymods eq 2) ? 5 : 1)
  if (keyvalue ge 5 and keyvalue le 10) then begin
    case keyvalue of
      5 : k.xx = (k.xx-1*move+sz[1]) mod (sz[1])
      6 : k.xx = (k.xx+1*move+sz[1]) mod (sz[1])
      7 : k.yy = (k.yy+1*move+sz[2]) mod (sz[2])
      8 : k.yy = (k.yy-1*move+sz[2]) mod (sz[2])
      9 : k.zz = (k.zz+1*move+sz[3]) mod (sz[3])
      10 : k.zz = (k.zz-1*move+sz[3]) mod (sz[3])
    endcase
  endif
  ;   stop
  if string(character) eq 'q' then begin
    window.close
    return, 0
  endif
  min = k.im1.min
  max = k.im1.max
  k.im1.setdata, reform((*k.vol)[*, *, k.zz])
  k.im1.min = min
  k.im1.max = max
  k.im1.title = '('+string(k.xx, f=fmt)+', ' $
    +string(k.yy, f=fmt)+', ' $
    +string(k.zz, f=fmt)+')'

  k.im2.setdata, transpose(reform((*k.vol)[k.xx, *, *]))
  k.im2.yr = k.im1.yr
  k.im2.min = min
  k.im2.max = max
  k.im2.rgb_table = k.im1.rgb_table
  k.im2.title = 'X = '+string(k.xx, f=fmt)


  k.im3.setdata, reform((*k.vol)[*, k.yy, *])
  k.im3.xr = k.im1.xr
  k.im3.min = min
  k.im3.max = max
  k.im3.rgb_table = k.im1.rgb_table
  k.im3.title = 'Y ='+string(k.yy, f=fmt)

  k.p11.setdata, [0, sz[1]-1], replicate(k.yy, 2)
  k.p12.setdata, replicate(k.xx, 2), [0, sz[2]-1]
  k.p21.setdata, replicate(k.zz, 2), [0, sz[2]-1]
  k.p22.setdata, [0, sz[3]-1], replicate(k.yy, 2)
  k.p31.setdata, [0, sz[1]-1], replicate(k.zz, 2)
  k.p32.setdata, replicate(k.xx, 2), [0, sz[3]-1]
  window.uvalue=k
  window.refresh
  return, 0
end

function show_3d, vol1, min=min, max=max, ratio=ratio, $
  xr=xr, yr=yr, zr=zr, box_sz=box_sz, im1=im1, im2=im2, im3=im3

  on_error, 1
  vol=ptr_new(reform(vol1))
  origin=ptr_new(vol1)
  if n_elements(min) eq 0 then min=min(*vol)
  if n_elements(max) eq 0 then max=max(*vol)
  if n_elements(ratio) eq 0 then ratio=0
  if n_elements(box_sz) eq 0 then box_sz=0.4
  sz=size(*vol)
  xx=0.5*sz[1]
  yy=0.5*sz[2]
  zz=0.
  fmt='(i0)'
  xi = 0.08
  yi = 0.05
  xf = 0.98
  yf = 0.95
  pos1 = [xi, yi, xi+box_sz, yi+box_sz]
  pos2 = [xi+box_sz+0.1, yi, xf, yi+box_sz]
  pos3 = [xi, yi+box_sz+0.1, xi+box_sz, yf]
  w = window(dim=[8d2, 8d2], window_title='Volume Explorer')
  im1 = image_kh(reform((*vol)[*, *, zz]), $
    pos=pos1, /current, font_size=11, $
    axis=2, title='('+string(xx, f=fmt)+', '$
    +string(yy, f=fmt)+', '$
    +string(zz, f=fmt)+')', rgb_table=33, $
    min=min, max=max, aspect_ratio=ratio, xthick=2, ythick=2, $
    xtitle='X pix', ytitle='Y pix', $
    xr=xr, yr=yr)
  p11=plot([0, sz[1]-1], replicate(yy, 2), '--2', /over, color='gray')
  p12=plot(replicate(xx, 2), [0, sz[2]-1], '--2', /over, color='gray')

  im2=image_kh(transpose(reform((*vol)[xx, *, *])), $
    pos=pos2, /current, font_size=11, $
    axis=2, title='X = '+string(xx, f=fmt), rgb_table=33, $
    min=min, max=max, aspect_ratio=ratio, xthick=2, ythick=2, $
    xtitle='Z pix', ytitle='Y pix', $
    xr=zr, yr=yr)
  p21=plot(replicate(zz, 2), [0, sz[2]-1], '--2', /over, color='gray')
  p22=plot([0, sz[3]-1], replicate(yy, 2), '--2', /over, color='gray')

  im3=image_kh(reform((*vol)[*, yy, *]), $
    pos=pos3, /current, font_size=11, $
    axis=2, title='Y = '+string(yy, f=fmt), rgb_table=33, $
    min=min, max=max, aspect_ratio=ratio, xthick=2, ythick=2, $
    xtitle='X pix', ytitle='Z pix', $
    xr=xr, yr=zr)
  p31=plot([0, sz[1]-1], replicate(zz, 2), '--2', /over, color='gray')
  p32=plot(replicate(xx, 2), [0, sz[3]-1], '--2', /over, color='gray')
  cb3 = colorbar(target=im3, pos=[1, 0, 1.03, 1], /relative, $
    orient=1, textpos=1, ticklen=0.5, subticklen=0.5, $
    /border, thick=2)

  t1=text(0.6, 0.9, font_size=15, vertical_alignment=1, $
    '$\rightarrow$, $\leftarrow$ : $\pm$ X'+ $
    '!c!c$\uparrow$, $\downarrow$ : $\pm$ Y'+ $
    '!c!cPgUp, PgDn : $\pm$ Z'+$
    '!c!c+ Ctrl : $\times$ 5'+$
    '!c!cQ : Quit')

  w.uvalue = {im1:im1, im2:im2, im3:im3, vol:vol, origin:origin, $
    xx:xx, yy:yy, zz:zz, $
    p11:p11, p12:p12, p21:p21, p22:p22, p31:p31, p32:p32}
  w.keyboard_handler='volume_explorer_move'
  return, w
end