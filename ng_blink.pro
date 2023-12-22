pro ng_blink, img, title
  if n_elements(title) eq 0 then title = strarr(n_elements(img))
  for ii=0, n_elements(img)-1 do img[ii].hide = 1
  i=0
  t1 = text(50, img[0].window.dimensions[1]-50, '', $
            font_size=15, font_style=1, /dev)
  t2 = text(50, img[0].window.dimensions[1]-100, 'Exit: Q', font_size=15, font_style=1, /dev)
  
  REPEAT BEGIN
    A = GET_KBRD(/KEY_NAME)
    img[i].hide=0
    for ii = 0, n_elements(img)-1 do begin
      if ii ne i then img[ii].hide = 1
    endfor
    t1.string = string(i, f='(i0)')+'. '+title[i]
    i = i+1
    i = i mod n_elements(img)
;    if i gt n_elements(img)-1 then i = i-n_elements(img)
  ENDREP UNTIL A eq 'q'
  t1.delete
  t2.delete
end