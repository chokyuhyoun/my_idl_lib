function ringfilter, image, r1, r2, ker=ker
;+ 
; NAME:    ringfilter
; PURPOSE:
;         To apply ring-shaped filtering to an image
; CALLING SEQUENCCE:
;         result = ringfilter(image, r1, r2)
; INPUTS:
;         image      input image
;         r1         inner radius of the ring
;         r2         outer radius of the ring
; OUTPUT:
;        result     ring-filtered image
;- 

s=round(2*r2)
if s lt (2*r2) then s=s+1
if s mod 2 eq 0 then s=s+1

r = shift(dist(s), s/2, s/2)

ker = float(r ge r1 and r le r2)
ker=ker/total(ker)

return, convol(float(image), ker, center=1, edge_trun=1)
end

