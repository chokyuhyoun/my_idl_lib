pro find_procedure, word, dir=dir
  message, 'Finding procedures used "'+string(word)+'" word', /continue
  cd, current=c
  if n_elements(dir) eq 0 then dir=c
  file = file_search(dir, '*.pro', count=n)
  for i=0, n-1 do begin
    str = ''
    openr, lun, file[i], /get_lun
    match = 0
    while ~eof(lun) do begin
      readf, lun, str
      match = match + strmatch(str, '*'+word+'*', /fold_case)
    endwhile
    if match gt 0 then begin
      print, file[i]+': '+string(match, f='(i0)')
    endif
    free_lun, lun
  endfor
end