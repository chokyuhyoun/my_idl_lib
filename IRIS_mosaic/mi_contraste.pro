function mi_contraste, ima_in

dim = size(ima_in)
x = findgen(dim[1])
b = dim[2]/2.
a = dim[1]/2.
y = sqrt(b^2.*(1.- (x-dim[1]/2.)/(a^2.))-dim[2]/2.)
mask_mosaic = ima_in*0.
x0 = dim[1]/2.
y0 = dim[2]/2.
for i = 0, dim[1]-1 do begin
    for j = 0, dim[2]-1 do begin
        if (((i - x0)/(a))^2. + ((j - y0)/(b))^2.) le 1 then mask_mosaic[i,j] = 1.
    endfor
endfor

brightnessHistogram = HISTOGRAM(ima_in*mask_mosaic)
wb = where(brightnessHistogram ne 0)
lowoccurence = where(min((brightnessHistogram[wb])[1:*], pos) eq brightnessHistogram)
highoccurence = where(max((brightnessHistogram[wb])[1:*], pos) eq brightnessHistogram)

return, [lowoccurence, highoccurence]

end

