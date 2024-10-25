function search_bbso_obs_log, word, start_yr=start_yr, end_yr=end_yr
  if n_elements(start_yr) eq 0 then start_yr = 2010  
  if n_elements(end_yr) eq 0 then caldat, systime(/jul), m0, d0, end_yr
  url_list = []
  url2=obj_new('idlneturl')
  url2->setproperty, url_scheme='http'
  url2->setproperty, url_host='bbso.njit.edu/'
    for yr0=start_yr, end_yr do begin
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
          url2->setproperty, url_path='pub/archive/'+yr+'/'+mm+'/'+dd+'/bbso_logs_'+yr+mm+dd+'.txt'
          log = url2->get(/string_array)
          pos=where(strmatch(log, '*'+word+'*', /fold_case), n, /null)
          if n ne 0 then begin
            url_list = [url_list, url]
            print, url
          endif
        endfor
      endfor
    endfor
  obj_destroy, url2
  return, url_list
end

dum = search_bbso_obs_log('CYRA', start_yr=2010)
end