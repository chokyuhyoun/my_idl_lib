function gaussian_, x, p
  return, p[0]*exp(-0.5*((x-p[1])/p[2])^2.) + p[3]
end

function iris_gaussian_fit, wv0, specp0, si_cen=si_cen, w_th_si=w_th_si, w_inst=w_inst, init=init, st=st
  fwhm_to_sig = 0.42466 ; 1./(2.*sqrt(2.*alog(2))) ; FWHM * FWHM_fac = Gaussian sigma
  if n_elements(si_cen) eq 0 then si_cen = 1402.77d0
  if n_elements(w_th_si) eq 0 then begin
    w_th_si = get_th_wid(si_cen, 28.0855, 4.9); gaussian sigma
    ;; ~ 0.053 angstrom in FWHM (https://iris.lmsal.com/itn38/diagnostics.html --> 0.05)
  endif

  if n_elements(w_inst) eq 0 then w_inst = 0.026*fwhm_to_sig ; in angstrom
  real = where(finite(specp0))
  wv = wv0[real]
  specp = specp0[real]

  min_width = sqrt(w_inst^2. + w_th_si^2.)
  if n_elements(init) eq 0 then init0 = [1., si_cen, min_width+1e-3, 0.] $
  else init0 = init

  lims = {value:0., fixed:0, limited:[0, 0], limits:[0., 0.]}
  lims = replicate(lims, n_elements(init0))
  lims[0].limited[0] = 1 & lims[0].limits[0] = 0d                        ; amplitude
  lims[1].limited[*] = 1 & lims[1].limits = si_cen+[-1, 1]*0.5         ; central wavelength
  lims[2].limited[*] = 1 & lims[2].limits = [min_width, 0.5]             ; width

  err = sqrt(specp>1e-2)
  res = mpfitfun('gaussian_', wv, specp, err, init0, $
    parinfo=lims, quiet=1, weights=1d, $/specp, $
    maxiter=400, status=st, ftol=1d-9, /nan)
  chisq = total((specp - gaussian_(wv, res))^2./err^2.)/(n_elements(specp) - n_elements(init0))
  res = [res, chisq]
  return, res
end