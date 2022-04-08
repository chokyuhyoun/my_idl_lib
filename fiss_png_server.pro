path='/data/fiss/2013/'
cd, path
mon=file_search('', /test_dir)
for i=0, n_elements(mon)-1 do begin
    cd, strcompress(path+mon[i]+'/', /remove_all)
    day=file_search('', /test_directory, /mark_dir)
    for j=0, n_elements(day)-1 do begin
        if strmatch(day[j], '*test*') eq 1 then goto, next_day
        cd, strcompress(path+mon[i]+'/'+day[j]+'/'+'comp/', /remove_all)
        obj1=file_search('', /test_dir)
        obj=obj1[where(obj1 ne 'cal')]
        for k=0, n_elements(obj)-1 do begin
;            if i eq 0 and j eq 0 and k eq 0 then goto, next_obj
            cd, strcompress(path+mon[i]+'/'+day[j]+'/'+'comp/'+obj[k]+'/', /remove_all)
            fiss_file=file_search('*_?.fts')
;            stop
            fiss2png, fiss_file, $
                      subdir=strcompress('/data/home/chokh/fiss/13'+mon[i] $
                                          +day[j]+path_sep()+obj[k], /remove_all)
;            stop
            next_obj:                                              
        endfor
        next_day:
    endfor
endfor 

end