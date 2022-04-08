; Name : distortion_cor.pro
; 
; Purpose : modification for the distortion of observational CCD data 
;           using catalog data.
;
; Calling sequence : 
; 
;    distortion_cor, file_name, cat_data, mag_cut=mag_cut, fit_order=fit_order, /save
; 
; Input 
;    - file_name : fitsfile name for correction
; 
;    - cat_data : catalog data file (RA, Dec, Magnitude)
; 
; Output : modified file ( name = n + [original file name] )
;          - chanage the data, header(CRVAL1, CRVAL2)
;          - add FITORDER 
;  
; Option : 
;    - mag_cut : catalog magnitude cut for finding offset value 
;                between CCD data and catalog data
;                defalut = 23 mag  
;    - sigma : setting the data value cut ( = median(data) + sigma * stddev(data))
;              for finding offset value between CCD data and catalog data
;              default = 0.8 
;    - fit_order : fitting order to modify the CCD distortion
;                  default = 3
;    - save : save the fitting result image in sub directory "/result" 
;
; Necessary procedure
;    - ringfilter.pro / cr_mem.pro /drivatives.pro : remove cosmic ray
;    - alignoffset.pro : find offset value between two image
;    + astron library
;
; History : Written 21 Jan 2014, Kyuhyoun Cho (SNU)
;              

pro distortion_cor, file_name, cat_data, $
                    mag_cut=mag_cut, fit_order=fit_order, sigma=sigma, save=save  


if n_params() ne 2 then $
   message, ' Syntax : distortion_cor, file_name, cat_data, mag_cut=mag_cut, ' +$
                       'sigma=sigma, fit_order=fit_order, /save' 
if size(file_name, /type) ne 7 or size(cat_data, /type) ne 7 then $
   message, 'Please check input files'

if ~keyword_set(mag_cut) then mag_cut=23.5  ; magnitude cut for artificial star
if ~keyword_set(fit_order) then fit_order=3.
if ~keyword_set(sigma) then sigma=0.8

ratio=5.  ; display & approximate alignment data ratio
dot=2.   ; artifact star radius
s_delta=50.   ; half side of sub region for precise alignment
vsym, 24

;;----------------------  read data
data=readfits(file_name, h, /sil)
sx=(size(data))[1]
sy=(size(data))[2]
w_xs=sx/ratio
w_ys=sy/ratio
crit=median(data)+sigma*stddev(data)  ; level of bright source for alignment
img_min=alog10(median(data)*0.8)
img_max=alog10(median(data)*0.8+1.5*stddev(data))
;stop

;data=data*(fxpar(h, 'EXPTIME')/582.157)  
if (where(data le 0d))[0] ne -1 then data[where(data le 0d)]=1.

;;----------------------  remove cosmic ray
n_data=cr_mem(data)

;; read catalog & find object inside the FOV of data
readcol, cat_data, f='d, d, d', ra, dec, mag, /sil

;window, 5, xs=w_xs, ys=w_ys
;loadct, 0, /sil
;tvscl, alog10(congrid(data, w_xs, w_ys))<img_max>img_min

adxy, h, ra, dec, x, y
inside=where((x gt 0.) and (x lt sx) and $
             (y gt 0.) and (y lt sy) and mag lt mag_cut)
x1=x[inside]
y1=y[inside]             


;window, 7, xs=w_xs, ys=w_ys
;vsym, 24
;tvscl, alog10(congrid(n_data, w_xs, w_ys))<img_max>img_min
;plots, x1/ratio, y1/ratio, psym=8, symsize=2, /dev, color=255. 
;plots, pix_x/ratio, pix_y/ratio, psym=8, symsize=1, /dev, color=0. 

;;----------------------  make artificial data
f_data=fltarr(sx, sy)+1.
for i=0, n_elements(inside)-1 do begin
    dot1=dot*(-mag[inside[i]]+mag_cut)  
    f_data[0>(x1[i]-dot1):(x1[i]+dot1)<(sx-1), $
           0>(y1[i]-dot1):(y1[i]+dot1)<(sy-1)]=crit
endfor    

sn_data=n_data
sn_data[where(sn_data lt crit)]=1.
sn_data[where(sn_data ge crit)]=crit
;
;window, 11, xs=w_xs*2., ys=w_ys
;tvscl, congrid(sn_data, w_xs, w_ys)<(0.5*crit), 0
;tvscl, congrid(f_data, w_xs, w_ys), 1
;plots, replicate(sx, 2)/ratio, [0, sy]/ratio, thick=2, $
;       color=255, /dev

;;----------------------  find offset of FOV
sn_data_min=congrid(sn_data, w_xs, w_ys)
f_data_min=congrid(f_data, w_xs, w_ys)
del1=alignoffset(sn_data_min, f_data_min)*ratio
;; del1 = (data - catalog) offset
;stop

;;----------------------  make new artificial data
ff_data=fltarr(sx, sy)+1.
nx=x+del1[0]
ny=y+del1[1]
inside1=where((nx gt 0.) and (nx lt sx) and $
              (ny gt 0.) and (ny lt sy) and mag lt mag_cut)
;stop
nx1=nx[inside1]
ny1=ny[inside1]
for i=0, n_elements(inside1)-1 do begin
    dot1=dot*(-mag[inside1[i]]+mag_cut)  
    ff_data[0>(nx1[i]-dot1):(nx1[i]+dot1)<(sx-1), $
            0>(ny1[i]-dot1):(ny1[i]+dot1)<(sy-1)]=crit
endfor    

;window, 16, xs=w_xs, ys=w_ys
;tvscl, alog10(congrid(n_data, w_xs, w_ys))<img_max>img_min
;plots, nx1/ratio, ny1/ratio, psym=8, symsize=2, /dev, color=255.
;stop

;;----------------------  find object inside the FOV of data
inside2=where((nx1 gt 1.*s_delta) and $
              (nx1 lt sx-1.*s_delta-1.) and $
              (ny1 gt 1.*s_delta) and $
              (ny1 lt sy-1.*s_delta-1.))
nx2=nx1[inside2]
ny2=ny1[inside2]

;window, 17, xs=w_xs, ys=w_ys
;tvscl, alog10(congrid(n_data, w_xs, w_ys))<img_max>img_min
;plots, nx2/ratio, ny2/ratio, psym=8, symsize=2, /dev, color=255.
;stop


;;---------------------- ; find offset for each object (function of x, y)
sig3=0.5*stddev(n_data)
ind=fltarr(n_elements(nx2))
del2=fltarr(2)
for j=0, n_elements(nx2)-1 do begin
    ff_data_piece=ff_data[nx2[j]-s_delta:nx2[j]+s_delta-1, $
                          ny2[j]-s_delta:ny2[j]+s_delta-1]
    n_data_piece=n_data[nx2[j]-s_delta:nx2[j]+s_delta-1, $
                        ny2[j]-s_delta:ny2[j]+s_delta-1]         
                                   
    if (where(n_data_piece gt sig3))[0] ne -1 then ind[j]=1.
    
    if j eq 0 then begin
        del2=alignoffset(ff_data_piece, n_data_piece)
    endif else begin    
        del2=[[del2], [alignoffset(ff_data_piece, n_data_piece)]]
    endelse
endfor

nnx=nx2[where((ind eq 1) and (finite(del2[0, *]) ne 0))]-del1[0] ; coord.
nny=ny2[where((ind eq 1) and (finite(del2[1, *]) ne 0))]-del1[1]
del2x=reform(-del2[0, where((ind eq 1) and (finite(del2[0, *]) ne 0))]+del1[0]) ;del
del2y=reform(-del2[1, where((ind eq 1) and (finite(del2[1, *]) ne 0))]+del1[1])

;window, 18, xs=w_xs, ys=w_ys
;tvscl, alog10(congrid(n_data, w_xs, w_ys))<img_max>img_min
;plots, nnx/ratio, nny/ratio, psym=8, symsize=2, /dev, color=255.
;loadct, 39, /sil
;plots, (nnx+del2x)/ratio, (nny+del2y)/ratio, psym=8, symsize=2, /dev, color=254
;loadct, 0, /sil
;stop


;;----------------------  1st fitting : del_x = f(x, y), del_y = g(x, y)


dum_x=sfit(transpose([[nnx+del2x], [nny+del2y], [-del2x]]), $
           fit_order, /irregular, kx=kx)
dum_y=sfit(transpose([[nnx+del2x], [nny+del2y], [-del2y]]), $
           fit_order, /irregular, kx=ky)

;window, 19, xs=w_xs, ys=w_ys
;tvscl, alog10(congrid(n_data, w_xs, w_ys))<img_max>img_min
;plots, (nnx-dum_x)/ratio, (nny-dum_y)/ratio, $
;        psym=8, symsize=2.5, /dev, color=255
;loadct, 39, /sil
;plots, (nnx+del2x)/ratio, (nny+del2y)/ratio, psym=8, symsize=2, /dev, color=254
;loadct, 0, /sil
;stop


;;----------------------  2nd fitting : except the irregular( >10 pix) point 
inside3=where((abs(del2x+dum_x) lt 10.) and (abs(del2y+dum_y) lt 10.))
nnnx=nnx[inside3]
nnny=nny[inside3]
del3x=del2x[inside3]
del3y=del2y[inside3]   

dum_x=sfit(transpose([[nnnx+del3x], [nnny+del3y], [-del3x]]), $
           fit_order, /irregular, kx=kx)
dum_y=sfit(transpose([[nnnx+del3x], [nnny+del3y], [-del3y]]), $
           fit_order, /irregular, kx=ky)

;window, 20, xs=w_xs, ys=w_ys
;tvscl, alog10(congrid(n_data, w_xs, w_ys))<img_max>img_min
;plots, (nnnx-dum_x)/ratio, (nnny-dum_y)/ratio, $
;        psym=8, symsize=2.5, /dev, color=255
;loadct, 39, /sil
;plots, (nnnx+del3x)/ratio, (nnny+del3y)/ratio, psym=8, symsize=2, /dev, color=254
;loadct, 0, /sil
;stop

;;---------------------- make corrected data
p_x=findgen(sx)#replicate(1., sy) 
p_y=replicate(1.,sx)#findgen(sy)
x_move=fltarr(sx, sy)
y_move=fltarr(sx, sy)
for i=0, fit_order do for j=0, fit_order do begin  
    x_move=x_move+kx[j, i]*p_x^i*p_y^j
    y_move=y_move+ky[j, i]*p_x^i*p_y^j
endfor

;window, 21, xs=w_xs, ys=w_ys
;tvscl, congrid(x_move, w_xs, w_ys)
;stop

x_av_move=x_move[sx/2., sy/2.]
y_av_move=y_move[sx/2., sy/2.]

x_out=x_move-x_av_move
y_out=y_move-y_av_move
cor_data=reform(interpolate(data, p_x-x_out, p_y-y_out), sx, sy)

;window, 22, xs=w_xs, ys=w_ys
;tvscl, alog10(congrid(cor_data, w_xs, w_ys))<img_max>img_min
;plots, (x-x_av_move)/ratio, (y-y_av_move)/ratio, psym=8, symsize=1.5, /dev, color=255


;;---------------------- save the fitting result
if keyword_set(save) then begin  
    cd, current=c
    out_dir=strcompress(c+path_sep()+'result')
    file_mkdir, out_dir
    cd, out_dir
    window, 23, xs=w_xs, ys=w_ys, /pixmap
    loadct, 0, /sil
    tvscl, alog10(congrid(cor_data, w_xs, w_ys))<img_max>img_min
    loadct, 39, /sil
    plots, (x1-x_av_move)/ratio, (y1-y_av_move)/ratio, $
           psym=8, symsize=1.5, /dev, color=150
    dot_pos=strpos(file_name, '.', /reverse_search)
    write_png, strcompress('n'+strmid(file_name, 0, dot_pos+1)+'png', /remove_all), $
               tvrd(true=1)
    cd, c
    ;stop
    loadct, 0, /sil
endif

;;---------------------- header modification

keyword=strtrim(strmid(h, 0, 8), 2)
cdelt=dblarr(2)
if total(strmatch(keyword, 'PIXSCAL1')) then begin
        cdelt[0]=fxpar(h, 'PIXSCAL1')
        cdelt[1]=fxpar(h, 'PIXSCAL2')
endif
if total(strmatch(keyword, 'CDELT1')) then begin
    cdelt[0]=fxpar(h, 'CDELT1')
    cdelt[1]=fxpar(h, 'CDELT2')
endif 
    
cd=dblarr(2, 2)
if total(strmatch(keyword, 'CD1_1')) then begin
    cd[0, 0]=fxpar(h, 'CD1_1')
    cd[1, 0]=fxpar(h, 'CD1_2')
    cd[0, 1]=fxpar(h, 'CD2_1')
    cd[1, 1]=fxpar(h, 'CD2_2')
    c_ra=fxpar(h, 'CRVAL1')+(cd[0, 0]*x_av_move+cd[1, 0]*y_av_move)
    c_dec=fxpar(h, 'CRVAL2')+(cd[0, 1]*x_av_move+cd[1, 1]*y_av_move)
endif else begin
    c_ra=fxpar(h, 'CRVAL1')+x_av_move*cdelt[0]/3600d0
    c_dec=fxpar(h, 'CRVAL2')+y_av_move*cdelt[1]/3600d0
endelse
;print, c_ra-fxpar(h, 'CRVAL1')
;print, c_dec-fxpar(h, 'CRVAL2')

n_h=h
fxaddpar, n_h, 'CRVAL1', c_ra
fxaddpar, n_h, 'CRVAL2', c_dec
fxaddpar, n_h, 'FITORDER', fit_order, 'fitting order for distortion correction'

;;---------------------- save corrected data
writefits, strcompress('n'+file_name, /remove_all), float(cor_data), n_h 
;stop
end