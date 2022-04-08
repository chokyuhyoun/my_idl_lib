function text_bg, t_obj, margin=margin, fill_color=fill_color, $
  fill_transp=fill_transp, _extra=extra
  if n_elements(margin) eq 0 then margin = t_obj.font_size*0.2
  if n_elements(fill_color) eq 0 then fill_color = 'white'
  if n_elements(fill_transp) eq 0 then fill_transp = 15
  t_pos_dev = t_obj.convertcoord(t_obj.pos[[0, 2]], t_obj.pos[[1, 3]], /to_dev)
  pos = t_pos_dev[[0, 1, 3, 4]]+margin*[-1, -1, 1, 1]
  backg = polygon(pos[[0, 0, 2, 2]], pos[[1, 3, 3, 1]], /dev, $
    fill_background=1, fill_color=fill_color, $
    fill_transp=fill_transp, linestyle=6)
  t_obj.order, /bring_to_front
  ;  stop
  return, backg
end