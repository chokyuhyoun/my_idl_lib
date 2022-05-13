function image_kh, img, x, y, _extra=extra
  on_error, 2
  if n_elements(extra) eq 0 then extra={axis:2}
  if total(strmatch(tag_names(extra), 'axis', /fold_case)) eq 0 then $
    extra = create_struct(extra, 'axis', 2)
  img = reform(img)
  sz = size(img)
  case n_params() of
    1 : begin
      dx = 1
      dy = 1
      x = findgen(sz[1])
      y = findgen(sz[2])
    end
    3 : begin
      dx = x[1]-x[0]
      dy = y[1]-y[0]
    end
    else : message, 'Check the number of arguments', /continue
  endcase
  x1 = x-0.5*dx
  y1 = y-0.5*dy
  img1 = img
  if total(strmatch(tag_names(extra), 'over*', /fold_case)) eq 1 then begin
    x1 = [x[0]-1.5*dx, x1]
    y1 = [y[0]-1.5*dy, y1]
    img1 = MAKE_ARRAY(n_elements(x)+1, n_elements(y)+1, VALUE=!values.f_nan)
    img1[1, 1] = img
  endif
  
  if total(strmatch(tag_names(extra), 'xr*', /fold_case)) ne 0 then $
    extra.xr = extra.xr+0.5*dx*[-1, 1]
  if total(strmatch(tag_names(extra), 'yr*', /fold_case)) ne 0 then $
    extra.yr = extra.yr+0.5*dy*[-1, 1]
  if total(strmatch(tag_names(extra), 'pos*', /fold_case)) eq 0 and $
    total(strmatch(tag_names(extra), 'lay*', /fold_case)) eq 0 and $
    total(strmatch(tag_names(extra), 'over*', /fold_case)) eq 0 then $
    extra = create_struct(extra, 'position', [0.15, 0.15, 0.9, 0.85])
  if total(strmatch(tag_names(extra), 'font_size', /fold_case)) eq 0 then $
    extra = create_struct(extra, 'font_size', 13)
  if sz[0] eq 3 then begin
    im = objarr(sz[3])
    im[0] = image(img1[*, *, 0], x1, y1, _extra=extra, $
                  font_name='malgun_gothic', font_style=1)
    for i=1, sz[3]-1 do begin
      im[i] = image(img1[*, *, i], x1, y1, over=im[0])
    endfor
  endif else begin
  im = image(img1, x1, y1, _extra=extra, $
             font_name='malgun gothic', font_style=1)
  endelse
  return, im
end