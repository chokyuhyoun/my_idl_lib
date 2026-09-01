FUNCTION sync_fov_wheel_, oWin, x, y, delta, keymods

  graphic_obj = oWin.HitTest(x, y)
  IF ~ISA(graphic_obj) THEN RETURN, -1
  if n_elements(graphic_obj) ne 1 then return, -1
  xy = graphic_obj.ConvertCoord(x, y, /DEVICE, /TO_DATA)
  oWin.refresh, /disable
  u = oWin.UVALUE
  IF delta GT 0 THEN zoom = 0.90D ELSE zoom = 1.1D
  u.img.xr = (u.img.xr-xy[0])*zoom + xy[0]
  u.img.yr = (u.img.yr-xy[1])*zoom + xy[1]
  oWin.uvalue = u
  oWin.Refresh
  RETURN, 0
END

function mousedown_, oWin, x, y, iButton, KeyMods, nClicks
  graphic_obj = oWin.HitTest(x, y)
  IF ~ISA(graphic_obj) || (n_elements(graphic_obj) gt 1) THEN RETURN, -1

  u = oWin.uvalue
  if ibutton eq 2 then begin
    u.midbuttonDown = 1
    u.midcurx = x
    u.midcury = y
  endif  
  if ibutton eq 1 then begin
    oWin.refresh, /disable
    xy_data = (graphic_obj.ConvertCoord(x, y, /DEVICE, /TO_DATA))[0:1]
    if ~finite(u.x[0]) then begin
      u.x = list(xy_data[0])
      u.y = list(xy_data[1])
    endif else begin
      u.x.add, xy_data[0]
      u.y.add, xy_data[1]
    endelse
    for k=0, n_elements(u.point_plot)-1 do begin
      u.point_plot[k].setdata, u.x.toarray(), u.y.toarray()
      u.point_plot[k].order, /bring_to_front
    endfor
    oWin.refresh
  endif
  oWin.uvalue = u
  return, 0
end

function sync_fov_move_, oWin, x, y, button
  if oWin.uvalue.midbuttondown eq 0 then return, 0
  graphic_obj = oWin.HitTest(x, y)
  IF ~ISA(graphic_obj) THEN RETURN, -1
  if n_elements(graphic_obj) ne 1 then return, -1
  oWin.refresh, /disable
  u = oWin.uvalue
  xy = graphic_obj.ConvertCoord([u.midcurx, x], [u.midcury, y], /DEVICE, /TO_DATA)
  u.img.xr -= xy[0, 1] - xy[0, 0]
  u.img.yr -= xy[1, 1] - xy[1, 0]
  u.midcurx = x
  u.midcury = y
  oWin.uvalue = u
  oWin.Refresh
  RETURN, 0
END

function mouseup_, oWin, x, y, iButton, KeyMods, nClicks
  u = oWin.uvalue
  if ibutton eq 2 then u.midbuttondown = 0
  oWin.uvalue = u
  return, 0
end

function del_points_, oWin
  u = oWin.uvalue
  u.x = list(!values.f_nan)
  u.y = list(!values.f_nan)
  for k=0, n_elements(u.point_plot)-1 do begin
    u.point_plot[k].setdata, u.x.toarray(), u.y.toarray()
    u.point_plot[k].hide = 0
  endfor
  oWin.uvalue = u
  return, 0
end

function hide_points_, oWin
  u = oWin.uvalue
  for k=0, n_elements(oWin.uvalue.point_plot)-1 do begin
    u.point_plot[k].hide = (u.point_plot[k].hide + 1) mod 2
  endfor
  oWin.uvalue = u
  return, 0
end

function blink_, window, $
  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods
  window.refresh, /disable
  IF release THEN RETURN, 1
  char = string(character)
  if isASCII eq 1 then begin
    if char eq 'q' then begin
      window.close
      return, 0
    endif
    if char eq 'd' then dum = del_points_(window)
    if char eq 'h' then dum = hide_points_(window)
  endif
  window.refresh
  return, 0
end

pro get_points, img

w01 = img.window
x = list(!values.f_nan)
y = list(!values.f_nan)
p01_ = plot(x.toarray(), y.toarray(), '+', color='white', sym_thick=3, over=img)
p02_ = plot(x.toarray(), y.toarray(), '+', color='black', over=img)
point_plot = [p01_, p02_]
w01.uvalue = {$
  img:img, $
  midbuttondown:0L, midcurx:0l, midcury:0l, $
  x:x, y:y, $
  point_plot:point_plot}
w01.keyboard_handler='blink_'
w01.MOUSE_WHEEL_HANDLER = 'sync_fov_wheel_'
w01.mouse_down_handler = 'mousedown_'
w01.mouse_motion_handler = 'sync_fov_move_'
w01.mouse_up_handler = 'mouseup_'
w01.refresh

end
