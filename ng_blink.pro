pro ng_blink, img
  i=0.
  t1 = text(0.1, 0.9, string(i, f='(i0)'), font_size=15, font_style=1)
  t2 = text(0.1, 0.8, 'Press Q', font_size=15, font_style=1)
  REPEAT BEGIN
    A = GET_KBRD(/KEY_NAME)
    img[i].hide=0
    for ii = 0, n_elements(img)-1 do begin
      if ii ne i then img[ii].hide = 1
    endfor
    t1.string = string(i, f='(i0)')
    i=i+1
    if i gt n_elements(img)-1 then i = i-n_elements(img)
  ENDREP UNTIL A eq 'q'
  t1.delete
  t2.delete
end