function ng_blink_, window, $
  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods
  
  uval = window.uvalue
  IF release THEN RETURN, 1
  if isASCII eq 1 then begin
    uval.imgs[uval.loc].hide = 0
    uval.imgs[uval.loc].order, /bring_to_front
    for ii=0, n_elements(uval.imgs)-1 do if ii ne uval.loc then uval.imgs[ii].hide = 1
    uval.imgs[uval.loc].title = uval.titles[uval.loc]
;    stop
  endif
  uval.loc = (uval.loc + 1) mod n_elements(uval.imgs)
  window.uvalue = uval
  return, 0
end
  
pro ng_blink, imgs, titles=titles
  if ~keyword_set(titles) then titles = string(findgen(n_elements(imgs)), f='(i0)')
  w01 = imgs[0].window
  loc = 0
  w01.uvalue = {imgs:imgs, loc:loc, titles:titles}
  w01.keyboard_handler='ng_blink_'
end

;function ng_blink_, window, $
;  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods
;
;  imgs = window.uvalue.imgs
;  loc = 100 - imgs[0].background_transp
;  loc = (loc+1) mod n_elements(imgs)
;  IF release THEN RETURN, 1
;  if isASCII eq 1 then begin
;    ;    if string(character) eq '1' then begin
;    imgs[loc].order, /bring_to_front
;    imgs[0].background_transp = 100 - loc
;    ;    endif
;  endif
;  return, 0
;end
;
;pro ng_blink, imgs, title
;  w01 = imgs[0].window
;  imgs[0].background_transp = 100
;  w01.uvalue = {imgs:imgs}
;  w01.keyboard_handler='ng_blink_'
;end