function loc_win,  win_par,  profile=profile
;+
; History:
;         2008 October: J. Chae, first coded
;-


fwhmx=win_par[0]
if n_elements(win_par) ge 2 then fwhmy=win_par[1] else fwhmy=fwhmx
if n_elements(win_par) eq 3 then theta_deg=win_par[2] else theta_deg=0.
if n_elements(profile) eq 0 then profile = 'gaussian'

theta=theta_deg*!dtor
hwhm=[fwhmx, fwhmy]/2.


hh = round(max(hwhm))
if profile eq 'top-hat' then mf=1 else mf=2
nxs = 2*hh*mf+1
nys = 2*hh*mf+1
xs=(indgen(nxs)-nxs/2) # replicate(1, nys)
ys=replicate(1, nxs) # (indgen(nys)-nys/2)

r2=((xs*cos(theta)+ys*sin(theta))/hwhm[0])^2 + $
  ((-xs*sin(theta)+ys*cos(theta))/hwhm[1])^2

case profile of
   'top-hat':   w = float(r2 le 1.)
   'gaussian': w = exp(-alog(2.)*r2)
   'hanning':  w = (1+cos(!pi/2.*(sqrt(r2)<2.0)))/2.
end

return, w
end
