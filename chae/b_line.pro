;+       
;       
; NAME :  B_LINE       
; PURPOSE :       
;         Calculates a field line given a 3-dimensional B field       
; CALLING SEQUENCE :       
;         B_LINE, Bx, By, Bz, R0, R, Dx=Dx, Dy=Dy, Dz=Dz,Ds=Ds       
; INPUTS:       
;         Bx, By, Bz : 3-dimensional arrays of B components       
;         R0 : starting point (1-d array with 3 elements)        
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
;         length : return total length of the field line. 
; OUPUTS :       
;         R : 2-d array. A series of spatial points defining       
;         the field line. 3 x N elements. N : number of       
;         elements.       
; RESTRICTION:       
;         R0 should be inside the spatial domain defined by       
;                          0 =< x =< (Nx-1)*Dx       
;                          0 =< y =< (Ny-1)*Dy       
;                          0 =< Z =<  zmax      
;        and integration will be done while        
;        while the spatial points are inside that domain.       
; Modfication History          
;  June 1997, Jongchul Chae       
;-       
pro b_line, bx, by, bz,r0, r, dx=dx, dy=dy,dz=dz, ds=ds, rev=rev, length=length      
       
nx = n_elements(bx(*,0,0))       
ny = n_elements(bx(0,*,0))       
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
r2=r0       
inside = r2(0)*(r2(0)-xmax) le 0. and  $       
         r2(1)*(r2(1)-ymax) le 0. and  $       
         r2(2)*(r2(2)-zmax) le 0.
      
if not inside then begin                
 tmp=widget_message('Starting point is outside the spatial domain.',/error)       
return       
endif else begin       
r=!null
;r=[transpose(r2)]   
zindex = (r2(2)/dz(0))^(1./dz(1))  
b0 = [interpolate(bx, r2(0)/dx, r2(1)/dy, zindex), $       
      interpolate(by, r2(0)/dx, r2(1)/dy, zindex), $       
      interpolate(bz, r2(0)/dx, r2(1)/dy, zindex)]       
b0=b0/norm(b0)       
endelse       
b2 = b0
       
while inside do begin       
r=[r, transpose(r2)]
r1=r2       
b1=b2     
iter2=0     
repeat begin       
r2_0 =r2       
r2=r1+(b1+b2)*0.5*ds
zindex = (r2(2)/dz(0))^(1./dz(1))     
b2 = [interpolate(bx, r2(0)/dx, r2(1)/dy, zindex), $       
      interpolate(by, r2(0)/dx, r2(1)/dy, zindex), $       
      interpolate(bz, r2(0)/dx, r2(1)/dy, zindex)]   
b2=b2/norm(b2)             
iter2=iter2+1       
   
endrep until (norm(r2_0-r2) le ds*0.2) or iter2 ge 10       
;print, 'iter2=', iter2 
;plots, [r1(0), r2(0)]*f+(f-1)/2.,[r1(1), r2(1)]*f+(f-1)/1, /dev     
;r=[r, transpose(r2)]       
inside = r2(0)*(r2(0)-xmax) le 0. and  $       
         r2(1)*(r2(1)-ymax) le 0. and  $       
         r2(2)*(r2(2)-zmax) le 0.       
limit = ((size(r))[1] gt 1d3) ? 0 : 1
inside=inside*limit  
endwhile        

if rev then begin
  r2 = r0
  b2 = b0
  inside = 1
  r_ = !null
  while inside do begin
    r_=[transpose(r2), r_]
    r1=r2
    b1=b2
    iter2=0
    repeat begin
      r2_0 =r2
      r2=r1+(b1+b2)*0.5*ds*(-1)
      zindex = (r2(2)/dz(0))^(1./dz(1))
      b2 = [interpolate(bx, r2(0)/dx, r2(1)/dy, zindex), $
        interpolate(by, r2(0)/dx, r2(1)/dy, zindex), $
        interpolate(bz, r2(0)/dx, r2(1)/dy, zindex)]
      b2=b2/norm(b2)
      iter2=iter2+1
  
    endrep until (norm(r2_0-r2) le ds*0.2) or iter2 ge 10
    ;print, 'iter2=', iter2
    ;plots, [r1(0), r2(0)]*f+(f-1)/2.,[r1(1), r2(1)]*f+(f-1)/1, /dev
    inside = r2(0)*(r2(0)-xmax) le 0. and  $
      r2(1)*(r2(1)-ymax) le 0. and  $
      r2(2)*(r2(2)-zmax) le 0.
    limit = ((size(r_))[1] gt 1d3) ? 0 : 1
    inside=inside*limit
  endwhile
  
  if n_elements(r_) gt 3 then r = [r_, r]
endif

if n_elements(r) gt 3 then begin 
  length = total(sqrt(total((r[1:*, *] - r[0:-2, *])^2., 2)))
endif else length=0      
end       

  
                         
                       
       
