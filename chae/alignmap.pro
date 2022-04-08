;\begin{verbatim}
function alignmap, object_image, alignpar, xrange, yrange, mag=mag 
;+
; NAME: alignmap
; PURPOSE: Determine a new image alingned with the reference image
; CALLING SEQUENCE:
;      New_Image = alignmap(Object_Image, alignpar, xrange, yrange)
; INPUTS:
;  Object_Image  object image to be alingned with the reference image
;  alignpar      alignment parameters, a structure variable
;                which is consitent with the structure
;                defined by alignstr().
;  xrange        the mapping range of x-direction indice of 
;                the reference image, a two-element array
;  yrange        the range of y-direction indice, atwo-element array
; KEYWORD INPUT:
;  mag           the magnification factor (default=1)
;- 
ns = n_elements(alignpar)
if n_elements(mag) eq 0 then mag=1
l = findgen((xrange(1)-xrange(0)+1)*mag)/mag+xrange(0)
l = l#replicate(1., (yrange(1)-yrange(0)+1)*mag) 
m = findgen((yrange(1)-yrange(0)+1)*mag)/mag+yrange(0)
m = replicate(1., (xrange(1)-xrange(0)+1)*mag)#m

l0 = alignpar.ref_origin(0)
m0 = alignpar.ref_origin(1)

i0 = alignpar.obj_origin(0)
j0 = alignpar.obj_origin(1)

theta = alignpar.rotation
q = alignpar.ref_aspect
r = alignpar.obj_aspect
s = alignpar.scale
f = alignpar.flip(0)
g = alignpar.flip(1)

tmp = (l-l0)*cos(theta) + q*(m-m0)*sin(theta)
i   = tmp/(s*f) + i0

tmp = -(l-l0)*sin(theta) + q*(m-m0)*cos(theta)
j  = tmp/(s*r*g) + j0


New_Image = interpolate(Object_image, i, j)

return, New_Image
end
;\end{verbatim}



     
