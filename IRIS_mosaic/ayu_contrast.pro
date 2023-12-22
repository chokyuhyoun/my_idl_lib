brightnessHistogram = HISTOGRAM(sclimg)


plot, brightnessHistogram
brightnessHistogram
      911453           0           0           0           0           0           0           0           0           0           0           0           0           0           0           0           0      139922           0           0
           0           0           0           0           0           0           0           0           0           0           0      163953           0           0           0           0           0           0           0           0
           0           0           0      182471           0           0           0           0           0           0           0           0           0           0      195985           0           0           0           0           0
           0           0           0      200343           0           0           0           0           0           0           0      197960           0           0           0           0           0           0           0      184920
           0           0           0           0           0      167957           0           0           0           0           0           0      146143           0           0           0           0      123096           0           0
           0           0           0       99572           0           0           0           0       77734           0           0           0           0       59330           0           0           0       44087           0           0
           0       31830           0           0           0       22789           0           0           0       15872           0           0           0       10949           0           0        7424           0           0           0
        5028           0           0        3446           0           0        2370           0           0        1672           0           0        1273           0         886           0           0         637           0           0
         488           0         365           0           0         340           0         257           0         233           0         170           0         151           0           0         147           0         132           0
          99           0          98         112           0          87           0         103           0          78           0          64          81           0          61          64           0          63           0          61
          44           0          44          73          54           0          57          52           0          44          48          45           0          41          62          49          30           0          38          31
          45          39          37          36          30           0          29          44          36          36          36          31          37          34          26          35          32          39          39          57
          28          29          24          29          21          26          54          23          35          23          67          26          23          23          57
wb = where(brightnessHistogram ne 0)
lowoccurence = where(min((brightnessHistogram[wb])[1:*], pos) eq brightnessHistogram)
         244
highoccurence = where(max((brightnessHistogram[wb])[1:*], pos) eq brightnessHistogram)
          63
tv, bytscl(sclimg, min=highoccurence*.20, max = lowoccurence*.8)

tv, bytscl(sclimg, min=highoccurence*.20, max = lowoccurence*.8)

sclimg_cg= congrid(sclimg, 334, 1001)
window, xs=334, ys=1002
tvscl, sclimg_cg

dim = size(sclimg_cg)
x = findgen(dim[1])
b = dim[2]/2.
a = dim[1]/2.
y = sqrt(b^2.*(1.- (x-dim[1]/2.)/(a^2.))-dim[2]/2.)
aux = sclimg_cg*0.
x0 = dim[1]/2.
y0 = dim[2]/2.
for i = 0, dim[1]-1 do begin
    for j = 0, dim[2]-1 do begin
        if (((i - x0)/(a))^2. + ((j - y0)/(b))^2.) le 1 then aux[i,j] = 1.
    endfor
endfor
tvscl, aux*sclimg_cg



dim = size(sclimg)
x = findgen(dim[1])
b = dim[2]/2.
a = dim[1]/2.
y = sqrt(b^2.*(1.- (x-dim[1]/2.)/(a^2.))-dim[2]/2.)
aux = sclimg*0.
x0 = dim[1]/2.
y0 = dim[2]/2.
for i = 0, dim[1]-1 do begin
    for j = 0, dim[2]-1 do begin
        if (((i - x0)/(a))^2. + ((j - y0)/(b))^2.) le 1 then aux[i,j] = 1.
    endfor
endfor
window, xs = dim[2], ys = dim[1]
tvscl, transpose(aux*sclimg)

mask_mosaic = aux
brightnessHistogram = HISTOGRAM(sclimg*mask_mosaic)
wb = where(brightnessHistogram ne 0)
lowoccurence = where(min((brightnessHistogram[wb])[1:*], pos) eq brightnessHistogram)
         244
highoccurence = where(max((brightnessHistogram[wb])[1:*], pos) eq brightnessHistogram)
          63
tv, bytscl(sclimg, min=highoccurence*.20, max = lowoccurence*.8)

window, xs = dim[2], ys = dim[1]
tv, bytscl(transpose(sclimg), min=highoccurence*.20, max = lowoccurence*.8)
perc = 5
tv, bytscl(transpose(sclimg), min=highoccurence*(perc/100.), max = highoccurence*((200-perc)/100.))






