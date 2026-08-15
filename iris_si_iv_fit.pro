;function gaussian_, x, p
;  return, p[0]*exp(-0.5*((x-p[1])/p[2])^2.) + p[3]
;end
;
;function get_th_wid, wave, a_mass, logt, $
;                     fwhm=fwhm, one_over_e=one_over_e, gaussian_sigma=gaussian_sigma
;;  k_b = 1.3806e-16 ;erg/K
;;  c = 2.9979e10 ;cm/s
;;  m_u = 1.6605d-24 ;g
;;  gaussian_sigma_factor = 1 (default)
;;  k_b/c^2./m_u = 9.251d-14
;;  in angstrom
;  if ~keyword_set(fwhm) then fwhm = 0
;  if ~keyword_set(one_over_e) then one_over_e = 0
;  
;  th_wid = 9.251d-14*(10.^logt)*wave^2./a_mass
;  th_wid = sqrt(th_wid)
;  factor = one_over_e ? sqrt(2) : (fwhm ? 2.*sqrt(2.*alog(2)) : 1)
;  th_wid *= factor
;  return,  th_wid
;end
;
;function gaussian_fit_, wv, specp, si_cen=si_cen, w_th_si=w_th_si, w_inst=w_inst, init=init, st=st
;  fwhm_to_sig = 0.42466 ; 1./(2.*sqrt(2.*alog(2))) ; FWHM * FWHM_fac = Gaussian sigma
;  if n_elements(si_cen) eq 0 then si_cen = 1402.77d0
;  if n_elements(w_th_si) eq 0 then begin
;    w_th_si = get_th_wid(si_cen, 28.0855, 4.9); gaussian sigma
;    ;; ~ 0.053 angstrom in FWHM (https://iris.lmsal.com/itn38/diagnostics.html --> 0.05)
;  endif
;
;  if n_elements(w_inst) eq 0 then w_inst = 0.026*fwhm_to_sig ; in angstrom
;
;  min_width = sqrt(w_inst^2. + w_th_si^2.)
;  if n_elements(init) eq 0 then init0 = [1., si_cen, min_width, 0.] $
;  else init0 = init
;
;  lims = {value:0., fixed:0, limited:[0, 0], limits:[0., 0.]}
;  lims = replicate(lims, n_elements(init0))
;  lims[0].limited[0] = 1 & lims[0].limits[0] = 0d                        ; amplitude
;  lims[1].limited[*] = 1 & lims[1].limits = si_cen+[-1, 1]*0.5         ; central wavelength
;  lims[2].limited[*] = 1 & lims[2].limits = [min_width, 0.5]             ; width
;
;  err = sqrt(specp>1e-2)
;  res = mpfitfun('gaussian_', wv, specp, err, init0, $
;    parinfo=lims, quiet=1, weights=1d, $/specp, $
;    maxiter=400, status=st, ftol=1d-9, /nan)
;  chisq = total((specp - gaussian_(res))^2./err^2.)/(n_elements(wv) - n_elements(init0))
;  res = [res, chisq]
;  return, res
;end


function iris_Si_IV_fit, raster_file, si_cen=si_cen

  if ~keyword_set(si_cen) then si_cen = 1402.77d0
  si_cen_str = string(round(si_cen), f='(i0)')
  
  w_th_si0 = get_th_wid(si_cen, 28.0855, 4.9)  ; in gaussian sigma,  angstrom
  w_inst = 0.026 ; in FWHM angstrom
  fwhm_to_sig = 1./(2.*sqrt(2.*alog(2))) ; FWHM * FWHM_fac = Gaussian sigma
  w_inst0 = w_inst*fwhm_to_sig    ; in Gaussian sigma
  
  pix_x_size=0.33   ; arcsec
  pix_y_size0=0.16635  ; arcsec
  en=1.986e-8/si_cen
  
  iris_hdr = fitshead2struct(headfits(raster_file))
  dd = iris_obj(raster_file)
  line_id = dd->getline_id()
  if total(strmatch(line_id, si_cen_str)) eq 0 then begin
    si_cen = 1393.755
    si_cen_str = string(round(si_cen), f='(i0)')
  endif
  si_id = (where(line_id eq 'Si IV '+ si_cen_str, /null))[0]
  sg_time = dd->ti2tai()
  exp_time0 = dd->getexp(iwin=si_id) ;; array
  exp_time = exp_time0[where(exp_time0 ne 0)]
  spec_bin = (dd->binning_spectral(si_id))[0]
  spat_bin = (dd->binning_region('FUV'))[0]
  pix_y_size = pix_y_size0*spat_bin
  
  resp = iris_get_response(anytim2utc(sg_time[0], /ccsds))
  getmin = min(abs(resp.lambda-si_cen/10.), imin)
  dn2phot_sg = resp.dn2phot_sg[0]
  pix_size=!pi/(180.)*!pi/(180.)*(pix_x_size/3600.)*(pix_y_size/3600.)
  area_sg = resp.area_sg[imin, 0]
  flux_per_dn = en*dn2phot_sg/area_sg/pix_size
  get_xp_yp_iris_raster, raster_file, xpos, ypos
  n_xpos = (size(xpos))[1]
  n_ypos = (size(ypos))[2]
  
  wv0 = dd->getlam(si_id)
  eff_wv = where(wv0 gt (si_cen-1) and wv0 lt (si_cen+1), /null, n_wv)
;  spectra = dblarr(n_wv, n_ypos, n_xpos)
  wv = wv0[eff_wv]*1d0
  exp_time_arr = rebin(reform(exp_time, 1, 1, n_xpos), $
    n_wv, n_ypos, n_xpos)
;  fit_res = fltarr(n_xpos, n_ypos, 4)
  spec0 = dd->getvar(si_id, /load) ; [wave, y, x]
  spectra = spec0[eff_wv, *, where(exp_time0 ne 0)]*flux_per_dn/exp_time_arr
;  spectra[where(spectra le 0)] = 0
  spec_max = reform(max(spectra, dim=1))
  spec_max_arr = rebin(reform(spec_max, 1, n_ypos, n_xpos), $
    n_wv, n_ypos, n_xpos)
  nor_spec = spectra / spec_max_arr
  nor_spec = reform(nor_spec, n_wv, n_xpos*n_ypos)
  n_cpu = !cpu.HW_NCPU-1
  if 1 then begin
    command = [$
      'res0 = iris_gaussian_fit(wv, nor_spec[*, i], $', $
      'si_cen=si_cen, w_th_si=w_th_si0, w_inst=w_inst0, st=st)', $ ;;amp0, cen0, wid0, lev0,
      'res = [[res], [res0]]']
    split_for, 0, n_xpos*n_ypos-1, command=command, $ ; fitting parameters = 1st dimension.
      ctvariable_name='i', varname=['wv', 'nor_spec', 'si_cen', 'w_th_si0', 'w_inst0'], $
      outvar='res', nsplit=n_cpu, $
      before_loop_commands=['res = !null']
  endif
;  stop
  fit_res = transpose(reform(res, 5, n_ypos, n_xpos), [2, 1, 0])
  
  amplitude = reform(fit_res[*, *, 0])*transpose(spec_max) ; in intensity unit
  velocity = reform((fit_res[*, *, 1] - si_cen)/si_cen*3d5) ; in km/s
  nth_width = (sqrt(reform(fit_res[*, *, 2])^2. - w_inst0^2. - w_th_si0^2.)>0d0)*sqrt(2)/si_cen*3d5 ; gaussian -> 1/e width
  chisq = reform(fit_res[*, *, 4])
  obj_destroy, dd
  
  res = {amp:amplitude, vel:velocity, nth:nth_width, chisq:chisq, $
    line_id:line_id[si_id], wave_cen:si_cen, xp:xpos, yp:ypos, $
    w_th:w_th_si0, w_instr:w_inst0, filename:raster_file, header:iris_hdr}
  return, res
end

