function ng_blink_, window, $
  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods
  
  imgs = window.uvalue.imgs
  arr = []
  for i=0, n_elements(imgs)-1 do arr = [arr, imgs[i].hide]
  loc = where(~arr, count)
  if count gt 1 then loc = loc[0]
  if count eq 0 then loc = 0
  new_loc = (loc+1) mod n_elements(arr)
  IF release THEN RETURN, 1
  if isASCII eq 1 then begin
;    if string(character) eq '1' then begin
      imgs[new_loc].hide = 0
      for i=0, n_elements(imgs)-1 do imgs[i].hide = (i eq new_loc) ? 0 : 1
;    endif
  endif
  return, 0
end
  
pro ng_blink, imgs, title
  w01 = imgs[0].window
  imgs[0].hide = 0
  for i=1, n_elements(imgs)-1 do imgs[i].hide=1
  w01.uvalue = {imgs:imgs}
  w01.keyboard_handler='ng_blink_'
end