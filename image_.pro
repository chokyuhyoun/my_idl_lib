function image_, img, x, y, xr=xr, yr=yr, high_res=high_res, over=over, _extra=extra
;  on_error, 2

  img = reform(img)
  sz = size(img)
  case n_params() of
    1 : begin
      dx = 1
      dy = 1
      x = findgen(sz[1])
      y = findgen(sz[2])
    end
    2 : begin
      dx = x[1]-x[0]
      dy = 1
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

  xr = (n_elements(xr) eq 0) ? minmax(x1)+[0, dx] : xr
  yr = (n_elements(yr) eq 0) ? minmax(y1)+[0, dy] : yr
  if n_elements(over) ne 0 then begin
    xr = over.xr
    yr = over.yr
  endif
  
  if n_elements(high_res) ne 0 then high_res, img1, x1, y1, xr, yr

  if n_elements(extra) eq 0 then begin
    extra={axis:2}
  endif
  if n_elements(over) ne 0 then begin
;      x1 = [x[0]-1.5*dx, x1]
;      y1 = [y[0]-1.5*dy, y1]
;      img1 = MAKE_ARRAY(n_elements(x)+1, n_elements(y)+1, VALUE=!values.f_nan)
;      img1[1, 1] = img
      im = image(img1, x1, y1, _extra=extra, over=over)
      ;    stop
    return, im
  endif

    if total(strmatch(tag_names(extra), 'axis', /fold_case)) eq 0 then $
      extra = create_struct(extra, 'axis', 2)
    if total(strmatch(tag_names(extra), 'pos*', /fold_case)) eq 0 and $
       total(strmatch(tag_names(extra), 'lay*', /fold_case)) eq 0 then $
      extra = create_struct(extra, 'position', [0.15, 0.15, 0.9, 0.9])
    if total(strmatch(tag_names(extra), 'font_size', /fold_case)) eq 0 then $
      extra = create_struct(extra, 'font_size', 13)
    if total(strmatch(tag_names(extra), 'aspect*', /fold_case)) eq 0 then begin
      sz = float(size(img1))
      aspect_ratio = (sz[1]/sz[2] gt 2 or sz[1]/sz[2] lt 0.5) ? 0 : 1
      extra = create_struct(extra, 'aspect_ratio', aspect_ratio)
    endif
            
    if sz[0] eq 3 then begin
      im = objarr(sz[3])
      im[0] = image(img1[*, *, 0], x1, y1, xr=xr, yr=yr, _extra=extra);, $
;                    font_name='malgun_gothic', font_style=1)
      for i=1, sz[3]-1 do begin
        im[i] = image(img1[*, *, i], x1, y1, xr=xr, yr=yr, over=im[0])
      endfor
    endif else begin
    im = image(img1, x1, y1, xr=xr, yr=yr, loc=[1000, 0], _extra=extra);, $
;               font_name='malgun gothic', font_style=1)
    endelse
    if im.xticklen ne im.yticklen then begin
      im.xticklen = im.xticklen < im.yticklen
      im.yticklen = im.xticklen
    endif
    return, im
end

