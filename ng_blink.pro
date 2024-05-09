function ng_blink_, window, $
  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods

  imgs = window.uvalue.imgs
  loc = 100 - imgs[0].background_transp
  loc = (loc+1) mod n_elements(imgs)
  IF release THEN RETURN, 1
  if isASCII eq 1 then begin
;    if string(character) eq '1' then begin
      imgs[loc].order, /bring_to_front
      imgs[0].background_transp = 100 - loc
;    endif
  endif
  return, 0
end
  
pro ng_blink, imgs, title
  w01 = imgs[0].window
  imgs[0].background_transp = 100
  w01.uvalue = {imgs:imgs}
  w01.keyboard_handler='ng_blink_'
end