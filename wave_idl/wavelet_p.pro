function wavelet_p, data, time1, avg_interval=avg_interval, $
          scale_avg=scale_avg, recon=recon, plot=plot, _extra=extra 

  if n_elements(avg_interval) lt 1 then avg_interval=[2., 4.]
  if n_elements(plot) lt 1 then plot=0
  if time1[0] gt 1d6 then time=(time1-time1[0])*1440d else time=time1
  dt=time[1]-time[0]
  xrange=minmax(time)
  pad=1
  s0=dt
  dj=1./8
  j1=10./dj
  mother='Morlet'
  cdelta=0.776
  psi0=!dpi^(-0.25)
  n=n_elements(time)

  wave=wavelet(data, dt, period=period, scale=scale, s0=s0, pad=pad, $
               coi=coi, dj=dj, j=j1, mother=mother)
  power=(abs(wave))^2.
  J = N_ELEMENTS(scale) - 1
  scale_average = REBIN(TRANSPOSE(scale),n,J+1)  ; expand scale-->(J+1)x(N) array
  power_norm = power/scale_average
  
  avg=where((scale ge avg_interval[0]) and (scale lt avg_interval[1]))
  scale_avg=dj*dt/cdelta*total(power_norm[*, avg], 2)
  recon=dj*sqrt(dt)/cdelta/psi0*(float(wave[*, avg])#(1./sqrt(scale[avg])))

  if plot then begin
    window, 11
    loadct, 39, /sil
    yrange = [16,0.5]   ; years
    levels = [0.001, 0.005, 0.01, 0.2]
    colors = [64,128,208,254]    
    period2 = FIX(ALOG(period)/ALOG(2))   ; integer powers of 2 in period
    ytickv = 2.^(period2(UNIQ(period2)))  ; unique powers of 2
    ytickv=ytickv(where(ytickv lt 20))

    plot, time, data, xr=xrange, xstyle=1, pos=[0.15, 0.7, 0.95, 0.9], $
          ystyle=2, yr=minmax(data)
    oplot, time, recon+mean(data), thick=2, linestyle=1
    
    CONTOUR,power,time,period,/NOERASE, pos=[0.15, 0.15, 0.95, 0.6], $
      XRANGE=xrange,YRANGE=yrange,/YTYPE, xstyle=1, ystyle=1, $
      YTICKS=N_ELEMENTS(ytickv)-1,YTICKV=ytickv, $
      LEVELS=levels,C_COLORS=colors,/FILL, $
      XTITLE='Time (min)',YTITLE='Period (min)', $
      TITLE='Wavelet Power Spectrum (contours at '+ $
            strjoin(string(levels, f='(f4.2)'), ', ')+$
            ' (km/s)!u2!n)' 

    x = [time(0),time,MAX(time)]
    y = [MAX(period),coi,MAX(period)]
    color = 4
    POLYFILL,x,y,ORIEN=+45,SPACING=0.5,COLOR=color,NOCLIP=0,THICK=1
    POLYFILL,x,y,ORIEN=-45,SPACING=0.5,COLOR=color,NOCLIP=0,THICK=1
    PLOTS,time,coi,COLOR=color,NOCLIP=0,THICK=1
  endif
;  stop  
  return, power
end 