iris_mosaic_catalog,/add,out
i = 124
set_plot,'ps'
donde = '/sanhome1/asainz/genuine_mosaic/'
str=donde+repstr(strmid(out(i).date_obs,0,10),'-','')
date_obs = strmid(str, strlen('/sanhome1/asainz/genuine_mosaic/'),8)
;
print
print, str
print, !d.name
print
print, date_obs
;spawn,'mv '+str+' '+str+'_iris_prep2.33'
;spawn,'mv '+str+' '+str+'_v1.0'
;
filename_txt = 'mosaic_'+date_obs+'.txt'
;filename_txt = 'mosaic_'+date_obs+'_rbld.txt'
openw, lun, filename_txt, /get_lun
printf, lun, '--------------------------------------------------------------------------------'
printf, lun, systime()
printf, lun, strcompress(i, /rem),' ', str
free_lun, lun
print, out[i].date_obs, out[i].date_end
iris_mosaic_maker, out[i].date_obs, out[i].date_end, str, /silent, /nodopp, nrt=0, force=0, kludge_fuv = 1
openw, lun, filename_txt, /get_lun, /append
printf, lun, systime()
printf, lun, '--------------------------------------------------------------------------------'
free_lun, lun
;iris_mosaic_web, '/sanhome1/asainz/genuine_mosaic/'+date_obs, /nodoppler, gamma_val=[1.,1.,0.4,0.3,0.5,0.5]
spawn, 'date +%Y', current_year
current_year = fix(current_year)
mi_iris_mosaic_web, '/sanhome1/asainz/genuine_mosaic/'+date_obs, /nodoppler, $
    pattern_year_web=current_year, only_html=0,  gamma_val=[1.,1.,0.4,0.3,0.5,0.5]
;;; For All in 1
mi_iris_mosaic_web, '/sanhome1/asainz/genuine_mosaic/'+date_obs, /nodoppler, $
    only_html=1,  gamma_val=[1.,1.,0.4,0.3,0.5,0.5]

