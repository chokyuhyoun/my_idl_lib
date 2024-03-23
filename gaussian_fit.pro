function gaussian, x, p
  return, p[0]*exp(-((x-p[1])/(2.*p[2]))^2.) + p[3]
end

function gaussian_fit, wv, specp, si_cen=si_cen, w_th_si=w_th_si, w_inst=w_inst, init=init
  if n_elements(si_cen) eq 0 then si_cen = 1402.77d0
  if n_elements(w_th_si) eq 0 then w_th_si = si_cen/3d8*sqrt(8.*alog(2.)*1.38d-23*10d0^(4.9)/(28.0855*1.6605d-27))  ; in angstrom
  ;; ~ 0.053 angstrom (https://iris.lmsal.com/itn38/diagnostics.html --> 0.05)
  if n_elements(w_inst) eq 0 then w_inst = 0.026 ; in angstrom

  min_width = sqrt(w_inst^2. + w_th_si^2.)
  if n_elements(init) eq 0 then init0 = [1., si_cen, min_width, 0.] $
  else init0 = init

  lims = {value:0., fixed:0, limited:[0, 0], limits:[0., 0.]}
  lims = replicate(lims, n_elements(init0))
  lims[0].limited[0] = 1 & lims[0].limits[0] = 0d                        ; amplitude
  lims[1].limited[*] = 1 & lims[1].limits = si_cen+[-1, 1]*0.5         ; central wavelength
  lims[2].limited[*] = 1 & lims[2].limits = [min_width, 0.5]             ; width

  err = sqrt(specp>0.)
  res = mpfitfun('gaussian', wv, specp, err, init0, $
    parinfo=lims, quiet=1, weights=1d, $/specp, $
    maxiter=400, status=st, ftol=1d-9, /nan)
  return, res
end