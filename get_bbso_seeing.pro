cd, 'C:\Users\chokh\Desktop\obs_log'


iday=julday(4, 1, 2014)
m1day=julday(6, 30, 2014)
m2day=julday(7, 1, 2014)
fday=julday(9, 30, 2014)
seeing=fltarr(3, fday-iday+1)
cloud=fltarr(3, fday-iday+1)
if 0 then begin
  for j=0, 2 do begin
    for i=0, fday-iday do begin
      day=iday+i+j*365d0
      caldat, day, mm, dd, yr
      mm=string(mm, f='(i02)')
      yr=string(yr, f='(i04)')
      dd=string(dd, f='(i02)')
      url='http://bbso.njit.edu/pub/archive/'+yr+'/'+mm+'/'+dd+$
        '/bbso_logs_'+yr+mm+dd+'.txt'
      log=webget(url)
      seeing_pos=where(strmatch(log.text, 'SEEING*'), n1)
      dum=where(strmatch(log.text, '*cloud*'), n2)
      seeing[j, i]=float(strmid(log.text[seeing_pos], 10, 1))
      ;    if seeing[j, i] eq 0 and n1 ne 0 then print, log.text[seeing_pos]
      if n1 eq 0 then seeing[j, i]=-1
      if n2 ne 0 then cloud[j, i]=1
    endfor
  endfor
  save, seeing, iday, fday, cloud, filename='seeing.sav'
endif else restore, 'seeing.sav'


dum=label_date(date_format=['%N/%d'])

set_plot, 'ps'
device, filename='seeing.eps', $
  /encapsulated, xs=17, ys=17, bits_per_pixel=8, /color, /isolatin1

ct=3
cs=1
loadct, 0, /sil
plot, indgen(2), /nodata, xr=[iday, m1day], $
  yr=[2013.3, 2016.8], xtickformat='label_date', $
  xstyle=1, ystyle=1, xticks=9, xthick=4, ythick=4, charthick=ct, charsize=cs, $
  ytickinterval=1, yticks=3, ytitle='Year', xtitle='Date', title='BBSO Seeing (2014 - 2016)', $
  yminor=1, pos=[0.1, 0.55, 0.95, 0.90]
for i=0, 2 do begin
  for j=0, m1day-iday do begin
    loadct, 39, /sil
    if seeing[i, j] eq -1 then pc=255
    if seeing[i, j] eq 0 then begin
      loadct, 0, /sil
      pc=200
    endif
    if seeing[i, j] eq 1 then pc=50
    if seeing[i, j] eq 2 then pc=150
    if seeing[i, j] eq 3 then pc=250
    plots, iday+j, 2014d0+i, psym=(cloud[i, j] eq 1) ? 7 : 8, $
      color=pc, symsize=1, thick=5
  endfor
endfor
loadct, 39, /sil
th=10
plots, [julday(6, 3, 2014), julday(6, 6, 2014)+1], 2014.15*[1, 1], thick=th
plots, [julday(6, 15, 2014), julday(6, 19, 2014)+1], 2015.15*[1, 1], thick=th
plots, [julday(6, 2, 2014), julday(6, 4, 2014)+1], 2016.15*[1, 1], thick=th
plots, [julday(6, 20, 2014), julday(6, 26, 2014)+1], 2016.15*[1, 1], thick=th

xyouts, julday(4, 05, 2014), 2016.5, '1"', color=50, /data, charsize=cs, charthick=ct
xyouts, julday(4, 15, 2014), 2016.5, '2"', color=150, /data, charsize=cs, charthick=ct
xyouts, julday(4, 25, 2014), 2016.5, '3"', color=250, /data, charsize=cs, charthick=ct
loadct, 0, /sil
xyouts, julday(5, 5, 2014), 2016.5, 'No features', color=200, /data, charsize=cs, $
  charthick=ct
xyouts, julday(5, 22, 2014), 2016.5, 'X : Cloud', color=0, /data, charsize=cs, charthick=ct
plots, [julday(6, 6, 2014), julday(6, 14, 2014)], replicate(2016.54, 2), $
  thick=10, /data
xyouts, julday(6, 16, 2014), 2016.5, 'FISS Obs.', color=0, /data, charsize=cs, charthick=ct


loadct, 0, /sil
plot, indgen(2), /nodata, xr=[m2day, fday], $
  yr=[2013.3, 2016.8], xtickformat='label_date', $
  xstyle=1, ystyle=1, xticks=9, xthick=4, ythick=4, charthick=ct, charsize=cs, $
  ytickinterval=1, yticks=3, ytitle='Year', xtitle='Date', $
  yminor=1, pos=[0.1, 0.1, 0.95, 0.45], /noerase
for i=0, 2 do begin
  for j=m2day-iday, fday-iday do begin
    loadct, 39, /sil
    if seeing[i, j] eq -1 then pc=255
    if seeing[i, j] eq 0 then begin
      loadct, 0, /sil
      pc=200
    endif
    if seeing[i, j] eq 1 then pc=50
    if seeing[i, j] eq 2 then pc=150
    if seeing[i, j] eq 3 then pc=250
    plots, iday+j, 2014d0+i, psym=(cloud[i, j] eq 1) ? 7 : 8, $
      color=pc, symsize=1, thick=5
  endfor
endfor
plots, [julday(7, 7, 2014), julday(7, 11, 2014)+1], 2014.15*[1, 1], thick=th
plots, [julday(7, 24, 2014), julday(7, 25, 2014)+1], 2015.15*[1, 1], thick=th


device, /close
set_plot, 'win'

end

