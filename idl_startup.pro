path = strsplit(!path, ':', /extract)
flag = strmatch(path, '*ssw*')
ssw_path = path[where(flag eq 1)]
default_path = path[where(flag eq 0)]
!path = strjoin([default_path, ssw_path], ':')
;!path = expand_path('<IDL_DEFAULT>'+':'+'/Users/khcho/IDLWorkspace/my_idl_lib-main'+':')+!path
;print, 'Changed the path order'
;strjoin([default_path, ssw_path], ':')
