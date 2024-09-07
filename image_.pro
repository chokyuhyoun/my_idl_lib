function image_, img, x0, y0, xr=xr, yr=yr, high_res=high_res, no_cb=no_cb, $
                  over=over, cb=cb, _extra=extra
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
      x = x0
      y = findgen(sz[2])
    end      
    3 : begin
      x = (x0 eq !null) ? findgen(sz[1]) : x0
      y = (y0 eq !null) ? findgen(sz[2]) : y0
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
  if n_elements(no_cb) eq 0 then no_cb = 0
  if n_elements(extra) eq 0 then extra = {axis:2}
  if total(strmatch(tag_names(extra), 'axis', /fold_case)) eq 0 then $
     extra = create_struct('axis', 2, extra)
  if total(strmatch(tag_names(extra), 'pos*', /fold_case)) eq 0 and $
     total(strmatch(tag_names(extra), 'lay*', /fold_case)) eq 0 and $
     (n_elements(over) eq 0) then $
    extra = create_struct('position', [0.15, 0.15, 0.85, 0.9], extra)
;    stop
  if total(strmatch(tag_names(extra), 'font_s*', /fold_case)) eq 0 then $
    extra = create_struct('font_size', 13, extra)
  if total(strmatch(tag_names(extra), 'aspect*', /fold_case)) eq 0 then begin $
    if n_elements(over) eq 0 then begin
      sz = float(size(img1))
      aspect_ratio = (sz[1]/sz[2] gt 2 or sz[1]/sz[2] lt 0.5) ? 0 : 1
      extra = create_struct('aspect_ratio', aspect_ratio, extra)
    endif else extra = create_struct('aspect_ratio', over.aspect_ratio, extra)
  endif
          
  if sz[0] eq 3 then begin
    im = objarr(sz[3])
    im[0] = image(img1[*, *, 0], x1, y1, xr=xr, yr=yr, _extra=extra)
    for i=1, sz[3]-1 do begin
      im[i] = image(img1[*, *, i], x1, y1, xr=xr, yr=yr, over=im[0])
    endfor
  endif else begin
    im = image(img1, x1, y1, xr=xr, yr=yr, over=over, loc=[1000, 0], $
               _extra=extra)
    if n_elements(over) eq 0 and no_cb ne 1 and $
       n_elements(where(finite(img1), /null)) then begin
      cb = colorbar(target=im, /normal, orientation=1, border=1, textpos=1, $
                    pos=im.pos[[2, 1, 2, 3]]+[0.01, 0, 0.03, 0])
    endif           
  endelse
  if im.xticklen ne im.yticklen then begin
    im.xticklen = im.xticklen < im.yticklen
    im.yticklen = im.xticklen
  endif
  return, im
end

