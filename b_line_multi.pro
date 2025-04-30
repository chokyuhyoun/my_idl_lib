function norm_multi, b0, keep_dim=keep_dim
  norm2 = sqrt(total(abs(b0)^2., 2))
  if n_elements(keep_dim) then return, rebin(norm2, (size(b0))[1], (size(b0))[2])
  return, norm2
    
end

function inside, r2, xmax, ymax, zmax, nreal=nreal
  r22 = reform(r2)
  inside0 = r22[*, 0]*(r22[*, 0]-xmax) le 0. and  $
            r22[*, 1]*(r22[*, 1]-ymax) le 0. and  $
            r22[*, 2]*(r22[*, 2]-zmax) le 0.
  nreal = total(inside0)          
  return, where(inside0, /null)
end


;+       
;       
; NAME :  B_LINE_MULTI       
; PURPOSE :       
;         Calculates field lines given a 3-dimensional B field       
; CALLING SEQUENCE :       
;         B_LINE, Bx, By, Bz, R0, R, Dx=Dx, Dy=Dy, Dz=Dz, Ds=Ds, length=length, flag=flag       
; INPUTS:       
;         Bx, By, Bz : 3-dimensional arrays of B components       
;         R0 : starting point [n, 3]        
; KEYWORD OPTIONAL INPUTS:       
;         Dx, Dy: increment values in x and y coordiantes       
;                  (Default=1)       
;         Dz : increment values in the z-direction
;               
;               It should be  a vector of two elements which define
;               a grid system    
;                   z = dz(0)*x^dz(1) (x=0, 1, .., Nz-1)               
;
;               Default is dz=[1, 1] (linear inrement)          
;                     
;         Ds : increment value of the arc length along the field       
;              lines( default=min(Dx, Dy, Dz))       
;              if Ds is negative, then the integration is done       
;              in the direction opposite to magnetic field.       
;         
;         rev : if set this keyword, calculate reverse direction also within the box.
;         
;         length : return total lengths of the field lines.
;         
;         flag
;           0: closed fields -- if z[0] eq 0 and z[-1] eq 0
;           1: Open fields -- if z[0] eq 0 and z[-1] eq zmax or vise versa
;           2: others --> otherwise, 2

; OUPUTS :       
;         R : [k, n, 3] array. series of spatial points defining       
;         the field line. k is length, n is number of points. 
;         length will be different each other, so some exceeding parts will be filled by Nan value.
;       
; Modfication History          
;  June 1997, Jongchul Chae
;  April 2025, Kyuhyoun Cho, Modified for multiple points using vectorization.       
;-       
pro b_line_multi, bx, by, bz, r0, r, dx=dx, dy=dy,dz=dz, ds=ds, 
                  rev=rev, length=length, flag=flag      

;r0 = [[100, 200], [100, 200], [50, 50]]       
nx = n_elements(bx(*,0,0))       
ny = n_elements(by(0,*,0))       
nz = n_elements(bz(0,0,*))       
   
if n_elements(dx) eq 0 then dx=1.       
if n_elements(dy) eq 0 then dy=1.       
if n_elements(dz) ne 2 then dz=[1.,1.]       
if n_elements(ds) eq 0 then ds=dx<dy<dz(0)       
if ~keyword_set(rev) then rev=1
       
xmax=(nx-1)*dx       
ymax=(ny-1)*dy 

z= dz(0)*findgen(nz)^dz(1)     
zmax=max(z)        
diag = sqrt(xmax^2. + ymax^2. + zmax^2.)

; r0 = [n, 3]
r0sz = size(r0)
r2=r0        
real0 = inside(r0, xmax, ymax, zmax, nreal=nreal0)
if nreal0 eq 0 then begin
  print, 'All starting points are outside the spatial domain.'
  r = r0
  length = fltarr(r0sz[1])
  return
endif else begin
  r=!null
  zindex = (r2[real0, 2]/dz(0))^(1./dz(1))
  b0 = r0*!values.f_nan  
  b0[real0, *] = [[interpolate(bx, r2[real0, 0]/dx, r2[real0, 1]/dy, zindex, missing=!values.f_nan)], $       
                  [interpolate(by, r2[real0, 0]/dx, r2[real0, 1]/dy, zindex, missing=!values.f_nan)], $       
                  [interpolate(bz, r2[real0, 0]/dx, r2[real0, 1]/dy, zindex, missing=!values.f_nan)]]       
  b0 = b0/norm_multi(b0, /keep_dim)       
endelse
b2 = b0
real = real0
nreal = nreal0       
while nreal ne 0 do begin
  ; r = [k, n, 3]       
  r=[r, reform(r2, 1, r0sz[1], r0sz[2])]
  r1=r2       
  b1=b2     
  iter2=0     
;  stop
  repeat begin       
    r2_0 =r2       
    r2=r1+(b1+b2)*0.5*ds
    zindex = (r2[real, 2]/dz(0))^(1./dz(1))  
    b2 = r2*!values.f_nan
    b2[real, *] = [[interpolate(bx, r2[real, 0]/dx, r2[real, 1]/dy, zindex, missing=!values.f_nan)], $       
                   [interpolate(by, r2[real, 0]/dx, r2[real, 1]/dy, zindex, missing=!values.f_nan)], $       
                   [interpolate(bz, r2[real, 0]/dx, r2[real, 1]/dy, zindex, missing=!values.f_nan)]]   
    b2=b2/norm_multi(b2, /keep_dim)             
    iter2=iter2+1       
  endrep until product(norm_multi(r2_0-r2) le ds*0.2) or iter2 ge 10       
  real = inside(r2, xmax, ymax, zmax, nreal=nreal)
  if ((size(r))[1] gt diag) then nreal = 0
;  stop
endwhile        
r=[r, reform(r2, 1, r0sz[1], r0sz[2])]
  
if rev then begin
  r2 = r0
  b2 = b0
  r_ = !null
  real = real0
  nreal = nreal0
  while nreal ne 0 do begin
    r_=[reform(r2, 1, r0sz[1], r0sz[2]), r_]
    r1=r2
    b1=b2
    iter2=0
    repeat begin
      r2_0 =r2       
      r2=r1-(b1+b2)*0.5*ds
      zindex = (r2[real, 2]/dz(0))^(1./dz(1))  
      b2 = r2*!values.f_nan
      b2[real, *] = [[interpolate(bx, r2[real, 0]/dx, r2[real, 1]/dy, zindex, missing=!values.f_nan)], $       
                     [interpolate(by, r2[real, 0]/dx, r2[real, 1]/dy, zindex, missing=!values.f_nan)], $       
                     [interpolate(bz, r2[real, 0]/dx, r2[real, 1]/dy, zindex, missing=!values.f_nan)]]   
      b2=b2/norm_multi(b2, /keep_dim)             
      iter2=iter2+1   
    endrep until product(norm_multi(r2_0-r2) le ds*0.2) or iter2 ge 10
    real = inside(r2, xmax, ymax, zmax, nreal=nreal)
    if ((size(r_))[1] gt diag) then nreal = 0
;    stop
  endwhile
  r_=[reform(r2, 1, r0sz[1], r0sz[2]), r_]
  if (size(r_))[1] gt 1 then r = [r_, r]
endif

length = (size(r))[1] gt 1 ? total(sqrt(total((r[1:*, *, *] - r[0:-2, *, *])^2., 3)), 1, /nan) : 0
  

line_size = (size(r))[1]
z_init = fltarr(r0sz[1]) + !values.f_nan
for t=0, line_size-1 do begin &$
  mask = where(finite(r[t, *, 2]) and finite(z_init, /nan), /null) &$
  z_init[mask] = r[t, mask, 2] &$
endfor

z_final = fltarr(r0sz[1]) + !values.f_nan
for t=line_size-1, 0, -1 do begin &$
  mask = where(finite(r[t, *, 2]) and finite(z_final, /nan), /null)  &$
  z_final[mask] = r[t, mask, 2]  &$
endfor

touch_floor = (abs(z_init) lt ds) + (abs(z_final) lt ds)
touch_ceil = (abs(z_init-zmax) lt ds) + (abs(z_final-zmax) lt ds)

flag = fltarr(r0sz[1]) + 2
flag[where(touch_floor eq 2, /null)] = 0
flag[where(touch_floor eq 1 and touch_ceil eq 1, /null)] = 1

      
end       

  
                         
                       
       
