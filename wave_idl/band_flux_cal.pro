function band_flux_cal, wv11, t1, wv22, t2, periods=periods, alpha=alpha, $
                        recon=recon, recon_wv1=recon_wv1, recon_wv2=recon_wv2, $
                        phase=phase
;  gamma=5./3.           ;;
;  g=981.*28.02          ;;
;  rho=1                 ;;
  dt=t1[1]-t1[0]
  pad=1
  s0=dt
  dj=1./16
  mother='Morlet'
  c=dj*dt/0.776
  cdelta=0.776
  psi0=!dpi^(-0.25)

  wv1=wv11
  wv2=wv22
  wavelet1=wavelet(wv1, dt, period=period1, scale=scale1, s0=s0, $
                   pad=pad, dj=dj, mother=mother)
  wavelet2=wavelet(wv2, dt, period=period2, scale=scale2, s0=s0, $
                   pad=pad, dj=dj, mother=mother) 
  j_int=where(period1 ge periods[0] and period1 le periods[1])
  nt=n_elements(t1)
  nj=n_elements(scale1)
 
  wave_coherency, wavelet1, t1, scale1, wavelet2, t2, scale2, $
                  wave_coher=wave_coher, wave_phase=wave_phase, $
                  time_out=time_out, scale_out=scale_out, $
                  power1=power1, power2=power2
  wave_phase=wave_phase*!dtor
  
  sarray=rebin(transpose(scale1), nt, nj)
  alpha=alog(total(abs(wavelet2[*, j_int])^2./sarray[*, j_int])/ $
             total(abs(wavelet1[*, j_int])^2./sarray[*, j_int]))
  
  
;  flux=gamma*g*rho/alpha* $
  flux=1.03*c/(2.*!dpi)* $
       total(abs(wavelet1[*, j_int])*abs(wavelet2[*, j_int])*wave_phase[*, j_int], 2)

  phase=mean(wave_phase[*, j_int], dim=2)*!radeg

  if n_elements(recon) then begin
    recon_wv1=dj*sqrt(dt)/cdelta/psi0*float(wavelet1[*, j_int])#(1./sqrt(scale1[j_int]))
    recon_wv2=dj*sqrt(dt)/cdelta/psi0*float(wavelet2[*, j_int])#(1./sqrt(scale2[j_int]))
  endif
      
  
  return, flux
end