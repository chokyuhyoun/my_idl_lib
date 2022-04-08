pro SunDisk_limb, image, xcenter, ycenter, rsun, delxc, delyc, cutlevel=cutlevel, $
       display=display, nolog=nolog

;+
;
; NAME :
;            SunDisk_limb
; CALLING SEQUENCE : SunDisk, image, xcenter, ycenter, rsun, dxc, dyc,$
;          cutlevel=cutlevel, display=display, nolog=nolog
; PURPOSE : 
;         Find the center and  radius of the Sun using limb gradients   
; ARGUMENT : 
;     IMAGE :  the image containing the solar limb (INPUT) 
;      XCENTER , YCENTER : x, y-coordinates of the sun disk (OUTPUT)
;              origin  = the lower left corner of the image.
;              unit     = pixel size
;              x-direction : from the left to right
;              y-direction : from the lower to the upper        
;       RSUN :  the radius of the sun disk (OUTPUT)
;       DXC , DYC: the standard deviation of XCENTER  
;                     and YCENTER (OPTIONAL OUTPUT)
; KEYWORD PARAMETERS : 
;      CUTLEVEL :  The level of cut used to define the limb points 
;             mag(gradient) > max(mag(gradient))*CUTLEVEL (Default=0.8)
;      DISPLAY : If set, display the process or the result.
;      NOLOG    if set,  gradients of input data are calculated. 
;                       By default,  logarithmic gradients of data  are calculated.                   
; REQUIRED ROUTINES :
;      NONE
;
;-                     

s=size(image)
x=findgen(s(1))#replicate(1., s(2))
y=replicate(1., s(1))#findgen(s(2))

kernelx = 0.5*[[0,0, 0],[-1, 0, 1], [0, 0, 0]]
kernely = 0.5*[[0,-1, 0], [0, 0, 0], [0, 1,0]]
if keyword_set(nolog) then tmp=image else tmp=alog(image>max(image)*0.1)
gx = convol(tmp, kernelx)
gy = convol(tmp, kernely)

g=sqrt(gx^2+gy^2)*(x ge 3 and x le s(1)-3) *( y ge 3 and y le s(2)-3)
if not keyword_set(cutlevel) then cutlevel=0.8
limb = where(g ge cutlevel*max(g), count)

if keyword_set(display) then begin
tvscl, tmp
if count ge 1 then plots, x(limb), y(limb), psym=1, /dev, syms=1.0
endif
if count le 10 then begin
print, '# of limb points is too small!'
return
endif
qx = -gx(limb)/g(limb)
qy = -gy(limb)/g(limb)
xdata = [transpose(qx), transpose(qy)]
ydata = x(limb)*qx + y(limb)*qy 
result = regress(xdata, ydata,1.+ydata*0., yfit,rsun, sigma,/relative_weight)
xcenter=result(0)
ycenter=result(1)
delxc = sigma(0)
delyc = sigma(1)
if keyword_set(display) then begin
angle=2*!pi*findgen(201)/200.
x=rsun*sin(angle)+xcenter
y=rsun*cos(angle)+ycenter
plots, x, y, color=0, /dev
endif
stop
return 
end
