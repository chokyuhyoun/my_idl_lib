cp /irisa/data/mosaic/mosaic_test.html mosaic_test_20210805.html

;;; Work with mi_iris_mosaic_web.pro
date_obs = '20210726'
iris_mosaic_web, '/sanhome2/asainz/genuine_mosaic/'+date_obs, /nodoppler ;, gamma_val=[1.,1.,0.4,0.3,0.5,0.5]

online mosaic.html -> mosaic_all.html
mosaic_test.html -> mosaic_test_all.html 
template_mosaic_year.html -> mosaic_YYYY.html

years = [2013,2014,2015,2016]

;;; For all the years
spawn, 'date +%Y', current_year
current_year = fix(current_year)
for j =2013, current_year[0] do mi_iris_mosaic_web, '/sanhome2/asainz/genuine_mosaic/'+date_obs, /nodoppler, pattern_year_web=j, only_html=1

date_obs = '20210909'
spawn, 'date +%Y', current_year
current_year = fix(current_year)
mi_iris_mosaic_web, '/sanhome1/asainz/genuine_mosaic/'+date_obs, /nodoppler, $
	pattern_year_web=current_year, only_html=1,  gamma_val=[1.,1.,0.4,0.3,0.5,0.5]


;;; For All in 1
mi_iris_mosaic_web, '/sanhome1/asainz/genuine_mosaic/'+date_obs, /nodoppler, $
	only_html=1,  gamma_val=[1.,1.,0.4,0.3,0.5,0.5]

