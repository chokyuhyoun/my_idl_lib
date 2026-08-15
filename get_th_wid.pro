function get_th_wid, wave, a_mass, logt, $
  fwhm=fwhm, one_over_e=one_over_e, gaussian_sigma=gaussian_sigma
  ;  k_b = 1.3806e-16 ;erg/K
  ;  c = 2.9979e10 ;cm/s
  ;  m_u = 1.6605d-24 ;g
  ;  gaussian_sigma_factor = 1 (default)
  ;  k_b/c^2./m_u = 9.251d-14
  ;  in angstrom
  if ~keyword_set(fwhm) then fwhm = 0
  if ~keyword_set(one_over_e) then one_over_e = 0

  th_wid = 9.251d-14*(10.^logt)*wave^2./a_mass
  th_wid = sqrt(th_wid)
  factor = one_over_e ? sqrt(2) : (fwhm ? 2.*sqrt(2.*alog(2)) : 1)
  th_wid *= factor
  return,  th_wid
end