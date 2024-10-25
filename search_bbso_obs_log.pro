function search_bbso_obs_log, word, start=start
  if n_elements(start) eq 0 then start = 2010  
  caldat, systime(/jul), m0, d0, y0
  date = []
  if 1 then begin
    for yr0=start, y0 do begin
      print, yr0
      for mm0=1, 12 do begin
        for dd0=1, 31 do begin
          yr = string(yr0, f='(i04)')
          mm = string(mm0, f='(i02)')
          dd = string(dd0, f='(i02)')
          url='http://bbso.njit.edu/pub/archive/'+yr+'/'+mm+'/'+dd+$
              '/bbso_logs_'+yr+mm+dd+'.txt'
  ;        log=webget(url)
          catch, errorStatus
          if (errorStatus ne 0) then continue
          url2=obj_new('idlneturl')
          url2->setproperty, url_scheme='http'
          url2->setproperty, url_host='bbso.njit.edu/'
          url2->setproperty, url_path='pub/archive/'+yr+'/'+mm+'/'+dd+'/bbso_logs_'+yr+mm+dd+'.txt'
          log = url2->get(/string_array)
          pos=where(strmatch(log, '*'+word+'*', /fold_case), n, /null)
;          stop
          if n ne 0 then begin
            date = [date, url]
            print, url
          endif
        endfor
      endfor
    endfor
  ;  save, seeing, iday, fday, cloud, filename='seeing.sav'
  endif
;  print, date
  return, date
end

dum = search_bbso_obs_log('CYRA')
end