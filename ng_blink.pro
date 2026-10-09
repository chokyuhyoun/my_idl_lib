function ng_blink_, window, $
  IsASCII, Character, KeyValue, X, Y, Press, Release, KeyMods
;  window.refresh, /disable
  uval = window.uvalue
  IF release THEN RETURN, 1
  if isascii eq 0 and keyvalue eq 5 then k = -1 else k = 1
  uval.loc = (uval.loc + n_elements(uval.imgs) + k) mod n_elements(uval.imgs)
  if isASCII eq 1 or (isascii eq 0 and (keyvalue eq 5 or keyvalue eq 6)) then begin
    uval.imgs[uval.loc].hide = 0
    uval.imgs[uval.loc].order, /bring_to_front
    for ii=0, n_elements(uval.imgs)-1 do if ii ne uval.loc then uval.imgs[ii].hide = 1
    uval.imgs[uval.loc].title = uval.titles[uval.loc]
;    stop
  endif
;  print, uval.loc
  window.uvalue = uval
  window.refresh
  return, 0
end
  
pro ng_blink, imgs, titles=titles
  if ~keyword_set(titles) then titles = string(findgen(n_elements(imgs)), f='(i0)')
  w01 = imgs[0].window
  loc = 0
  w01.uvalue = {imgs:imgs, loc:loc, titles:titles}
  w01.keyboard_handler='ng_blink_'
end