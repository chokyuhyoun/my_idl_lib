pro get_xp_yp_iris_raster, raster_file, xpos, ypos, r_sun=r_sun
  ;; xpos, ypos = [nstep, nslit] in arcsec
  h = headfits(raster_file)
  h1 = headfits(raster_file, ext=1)
  nstep = fxpar(h1, 'naxis3')
  nslit = fxpar(h1, 'naxis2')
  dstep = fxpar(h1, 'cdelt3')
  dslit = fxpar(h1, 'cdelt2')
  ext_ind = fxpar(h, 'nwin')+1
  sat_rot = fxpar(h, 'sat_rot')*!dtor
  aux_h = headfits(raster_file, ext=ext_ind)
  aux_info = readfits(raster_file, ext=ext_ind, /sil)
  xcenix = reform(aux_info[fxpar(aux_h, 'xcenix'), *])
  ycenix = reform(aux_info[fxpar(aux_h, 'ycenix'), *])
  xpos0 = fltarr(nstep, nslit)
  ypos0 = rebin(transpose((findgen(nslit) - 0.5*(nslit-1.))*dslit), nstep, nslit)
  xpos = xpos0*cos(sat_rot) + ypos0*sin(sat_rot) + rebin(xcenix, nstep, nslit)
  ypos = -xpos0*sin(sat_rot) + ypos0*cos(sat_rot) + rebin(ycenix, nstep, nslit)
  r_sun = 6.957d8/fxpar(h, 'dsun_obs')*180d0/!dpi*3600d0 ; in arcsec
end