;+ sig3.pro
; :Description:
;    return +- 3 sigma level of the image
;
; :Params:
;    img 
;
;
;
; :Author: chokh
;- '16. 09  first coded. 
function sig3, img
mean=mean(img)
std=stddev(img)
min=(mean-3.*std)>0.
max=(mean+3.*std)<max(img)
return, [min, max]
end