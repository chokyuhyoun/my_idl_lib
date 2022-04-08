;+
; :Description:
;    Find the bisector of the profile using Lambdameter method
;
; :Params:
;    wv : wavelength
;    spec : spectrum 
;    dlambda : half width for using bisector 
;              I(lambda-dlambda)=I(lambda+dlambda)
;
; :keyword:
;    center : central wavelength (e.g. 6563)
;
;
; :Author: chokh
;-

function lambdameter, wv, spec, dlambda, center=center, int=int, del1=del1
wv=double(wv)
spec=double(spec)
center=double(center)
dlambda=double(dlambda)

dl=wv[1]-wv[0]
if ~keyword_set(del1) then del1=15
if ~keyword_set(center) then begin
  cen_pix1=(where(spec eq min(spec)))[0]
  center1=wv[cen_pix]
endif else begin
  cen_pix=arr_eq(wv, center)
  cen_pix1=(where(spec[cen_pix-del1:cen_pix+del1] eq $
          min(spec[cen_pix-del1:cen_pix+del1])))[0]+cen_pix-del1
  center1=wv[cen_pix1]  
endelse

lmax=(where(spec[cen_pix1:cen_pix1+del1] eq max(spec[cen_pix1:cen_pix1+del1])))[0]+cen_pix1
spec1=reverse(spec[cen_pix1-3:lmax]) 
wv1=reverse(wv[cen_pix1-3:lmax])
left=(center1-dlambda)[0]
rep=0
del=0.

repeat begin
  rep=rep+1
  left=left-0.5*del
  int=interpol(spec, wv, left)
;  spec1=spec[cen_pix1:cen_pix1+2.*del1]
;  r_pix=(where(spec1 gt int))[0]+cen_pix1
;  right=interpol(wv[r_pix-1:r_pix], spec[r_pix-1:r_pix], int, /spline)
  right=interpol(wv1, spec1, int)
  
  del=2d0*dlambda-abs(right-left)
;  print, rep, left, right, del
;  oplot, [left, right], [1, 1]*int, linestyle=1
;  stop
endrep until (rep eq 10) or (abs(del) lt 1d-3)
doppler=0.5*(right+left)

if abs(doppler) gt 1d4 then stop

;plot, wv, spec, xr=center+[-1, 1]*0.2, ystyle=3, psym=-1
;oplot, [left, right], replicate(int, 2), linestyle=1, thick=2
;oplot, doppler+[0, 0], [0, 1d4], linestyle=1
;stop

return, doppler

end