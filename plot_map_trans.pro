pro plot_map_trans, r_map, g_map, b_map, alpha=alpha, $
                    r_drange=r_drange, g_drange=g_drange, b_drange=b_drange, $
                    _extra=extra
  if ~keyword_set(alpha) then alpha=0.5
  if ~keyword_set(r_drange) then r_drange=mean(r_map.data)+2.*stddev(r_map.data)*[-1, 1]
  if ~keyword_set(g_drange) then g_drange=mean(g_map.data)+2.*stddev(g_map.data)*[-1, 1]
  if ~keyword_set(b_drange) then b_drange=mean(b_map.data)+2.*stddev(b_map.data)*[-1, 1] 
  if ~have_tag(extra, 'pos', /start) then p=[0.15, 0.15, 0.85, 0.85] else $
      p=extra.(where(strmatch(tag_names(extra), 'pos*', /fold) eq 1))
  cur_win=!d.window
  back=tvrd(true=3)
  
  window, /free, xs=!d.x_size, ys=!d.y_size, /pix
  new_win=!d.window
  x_start=p[0]*!d.x_vsize
  y_start=p[1]*!d.y_vsize
  x_size=round((p[2]-p[0])*!d.x_vsize)
  y_size=round((p[3]-p[1])*!d.y_vsize)
  r_img=fltarr(x_size, y_size)
  g_img=fltarr(x_size, y_size)
  b_img=fltarr(x_size, y_size)
  
  loadct, 0, /sil
  if valid_map(r_map) then begin
    plot_map_d, r_map, drange=r_drange, _extra=extra
    r_img=(tvrd())[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *]
  endif
  
  if valid_map(g_map) then begin
    plot_map_d, g_map, drange=g_drange, _extra=extra
    g_img=(tvrd())[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *]
  endif
  
  if valid_map(b_map) then begin
    plot_map_d, b_map, drange=b_drange, _extra=extra
    b_img=(tvrd())[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *]  
  endif
  fore=[[[r_img]], [[g_img]], [[b_img]]]
  back1=back[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *]
  inside=(1.-alpha)*temporary(back1)+alpha*temporary(fore)
  
  new_img=back
  new_img[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *] $
          =inside 
  wset, cur_win        
  tv,byte(temporary(new_img)),true=3
end
