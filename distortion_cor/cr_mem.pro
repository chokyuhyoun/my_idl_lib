;+
;
;   NAME : CR_MEM
;   PURPOSE :
;           Correct for cosmic ray like defect
;            based on MEM(Maximum Entropy Method)
;   CALLING SEQUENCE
;            New_image      = CR_MEM(Old_image)
;    INPUT:
;           Old_image :  image to be corrected (should be postive-definite)
;    KEYWORD INPUTS:
;           Size :   Spatial Resoution of the data
;                    It should be greater or equal to 1.  (default=2.0)
;           itmax:  maximum iteration number (default=20)
;                  If itmax is greater than 0, then maximum entropy
;                  iteration is done to refine the image. 
;           display: if set, the intermediate results are displayed.   
;           reference: used for a reference image if given.
;   OUTPUT:
;           New_image : corrected image
;   KEYWORD OUTPUTS:
;          Goodness: a measure of goodness of the original image quality
;   REQUIRED ROUTINES:   RINGFILTER
;   History
;      June 1997    Jongchul Chae
;      August 1998  Iteration based on maximum entropy method
;      October 1998 Changed Name
;      October 1999  use second derivative information (DERIVATIVES)
;                            and simplify the routine
;-                           
 
function cr_mem, image,  size=size, itmax=itmax,  display=display, $
reference=reference,  goodness=goodnees
if n_elements(size) eq 0 then size=2.0
;alpha=1.e-6
if n_elements(alpha) eq 0 then alpha=0.0001
if n_elements(itmax) eq 0 then itmax=30
if n_elements(display) eq 0 then display=0 else display=1

size=size>2.
size2=size/2
sz = size(image)

y=(image)
mm=float(median(y))

if keyword_set(reference) then m= reference $
else m=exp(ringfilter(alog(y), size, size+1))
y1=alog(abs(y-m)>(m*0.1))
xd = derivatives(y1, /second)
yd = transpose(derivatives(transpose(y1), /second))



fwhm=size
sigma=fwhm/(2*sqrt(2*alog(2)))

tmp =  sqrt(xd^2+yd^2) gt 3./sigma^2 & xd=0 & yd=0 & y1=0

ss= ringfilter(float(tmp), 0, size2)



ss([0, sz(1)-1], *) = 1.
ss(*, [0, sz(2)-1]) = 1. 

x=float(image)
l1=where(ss gt 0., count1)
l2=where(ss le 0., count2)
if  count1 eq 0 then return, x
if count1 ge 1 then x(l1) = m(l1)
goodnees=fix(float(count2)/(count1+count2)*100)


if display then begin
    window, 0, xs=sz(1), ys=sz(2)
    tvscl, alog(y/mm<4.>0.25)
    xyindex, x, xa, ya
    if count1 ge 1 then  plots, /dev, xa(l1), ya(l1), psym=3, color=0
    endif

if itmax le 0  then return, x



k=0
if itmax gt 0  and count1 ge 1 then repeat begin
x0=x
k=k+1
m= ringfilter(x, size2, size2+1)


 x(l1) = m(l1)
;yy=y(l2)/m(l2)
;if 0 and count2 ge 1 then  begin
;     xx=x(l2)/m(l2)
;     for j=0, 1 do xx =xx -(xx+alpha*alog(xx)-yy)/(1+alpha/xx)
;     x(l2) = xx*m(l2)  
; endif  

m2=max((x-x0)/x0, min=m1)

if display then begin
print, 'k =', k  & print, m2, m1 & tvscl, alog(x/mm<4.>0.25)
endif
endrep until  abs(m2)>abs(m1) le 0.001  or k eq itmax 
return, x
end









