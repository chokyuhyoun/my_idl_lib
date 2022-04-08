function change_extension, file, ext=ext
  if ~keyword_set(ext) then ext='png'
  dot_pos=strpos(file, '.', /reverse_search) 
  name=strarr(n_elements(file))
  for i=0l, n_elements(file)-1 do $
    name[i]=strmid(file[i], 0, dot_pos[i]+1)+ext
  return, name
end