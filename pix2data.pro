
; Name : pix2data
;
; Object : convert pixel number to data number
;
; Colling sequence : pix2data, pix_x, pix_y, map, data_x, data_y
;
; Input
; 
;   - pix_x : x_pixel array
;   
;   - pix_y : y_pixel array
;      
;   - map : header or map(structure) for the plot_map
;
;  Output
;  
;   - data_x : x_data array
;   
;   - data_y : y_data array
   
pro pix2data, pix_x, pix_y, h, data_x, data_y, $
              angle=angle, xs=xs, ys=ys
    dtor=!dpi/180d0
   if n_elements(pix_x) eq 0 or $
      n_elements(pix_y) eq 0 or $
      (size(h, /type) ne 7 and $
      size(h, /type) ne 8) then begin
      message, 'Incorrect argument. (!ºoº)!', /cont
      message, 'Argument : pix2data, pix_x, pix_y, header or map, data_x, data_y', /cont
   endif else begin   
      if size(h, /type) eq 7 then begin 
        if strmatch(fxpar(h, 'FISSMODE'), 'Spectrograph') then begin
           cdelt1=0.16
           cdelt2=0.16
           xsize=fxpar(h, 'NAXIS2')
           ysize=fxpar(h, 'NAXIS3')
        endif else begin
           cdelt1=fxpar(h, 'CDELT1')
           cdelt2=fxpar(h, 'CDELT2')
           xsize=fxpar(h, 'NAXIS1')
           ysize=fxpar(h, 'NAXIS2')
        endelse
        rot_ang=fxpar(h, 'rotation')*dtor
        if fxpar(h, 'REVERSE') then pix_y=ysize-pix_y
        cdata_x=fxpar(h, 'tel_xpos')
        cdata_y=fxpar(h, 'tel_ypos')
      endif else begin
        cdelt1=h.dx
        cdelt2=h.dy
        xsize=(size(h.data))[1]
        ysize=(size(h.data))[2]
        rot_ang=0.
        cdata_x=h.xc
        cdata_y=h.yc
      endelse
      if keyword_set(xs) then xsize=xs
      if keyword_set(ys) then ysize=ys
      if n_elements(angle) ne 0 then rot_ang=angle*dtor
      cpix_x=(xsize-1d)/2d
      cpix_y=(ysize-1d)/2d
      dist=sqrt((pix_x-cpix_x)^2.+(pix_y-cpix_y)^2.)
      ang=atan(pix_y-cpix_y, pix_x-cpix_x)
      data_x=cdata_x+dist*cos(ang-rot_ang)*cdelt1
      data_y=cdata_y+dist*sin(ang-rot_ang)*cdelt2
   endelse
   if ~n_elements(data_x) then begin
      data_x=!VALUES.F_NAN
      data_y=!VALUES.F_NAN
   endif      
end    
