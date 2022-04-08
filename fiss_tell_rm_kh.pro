
pro fiss_tell_model,  wv,  par, f
dwv = par[0]
amp=par[1]
disp=1.; par[2]
f=convol(-amp*fiss_tell_lines((wv-median(wv))*disp+median(wv)+dwv), [-1,1])
end

function fiss_tell_rm_kh, wv, sp, par, nofit=nofit

;+
;  Name: FISS_TELL_RM
;  Purpose:
;              Remove telluric lines from spectrogram
;  Calling sequence:
;              sp_new = fiss_tell_rm(wv, sp,  par, nofit=nofit)
;  Inputs
;           wv      array of wavelengths in angstrom
;           sp      spectrogram to be corrected
;  Optional input:
;           par      adjustment parameters for the model of optical depth
;                       recognized as an input when keyword NOFIT is set
;  Output:
;          sp_new    corrected spectrogram
;  Optional output
;          par    recognized as an output unless keyword NOFIT is set
;  Keyword
;         nofit    if set,  given adjustment parameters are used
;                     if not, parameters are internally determined. (default)
; History:
;      2010 Septmeber: J. Chae first coded
;      2015 January: K. Cho revised(could be calculate for only one proflie)
;-
if not keyword_set(nofit) then begin
par=[0., 1.0]
if (size(sp))[0] eq 1 then y=convol(alog(sp), [-1, 1]) $
                      else y=convol(alog(total(sp,2)/n_elements(sp[0,*])), [-1, 1])

res=curvefit(wv,  y,  fiss_tell_lines(wv) ge 0.02, par,  /noderivative, funct='fiss_tell_model')
endif
model=sp*(exp(par[1]*fiss_tell_lines((wv-median(wv))+median(wv)+par[0]))#replicate(1., n_elements(sp[0,*])))
;stop
return, model
end


;
ha=0
if ha then f=(file_search('D:\data\research\FISS data\110929\ar\*A1_c.fts'))[50] else $
f=(file_search('D:\data\research\FISS data\110929\ar\*B1_c.fts'))[50]
wv=fiss_wv(f)
d=fiss_read_frame(f, 50)
if  ha  then wc=6562.817d0  else wc=8542.089d0
par=[0,1,1.]
d1=fiss_tell_rm(wv+wc, d, par, nofit=0)
print, par
window, 2, xs=512, ys=256*2
if ha then begin
tvscl, d, 0
tvscl, d1, 1
endif else begin
tvscl, rotate(d,5),0
tvscl, rotate(d1,5), 1
endelse
end