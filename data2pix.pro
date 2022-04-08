
; Name : data2pix
;
; Object : convert data numbers to pixel numbers
;
; Colling sequence : data2pix, data_x, data_y, h, pix_x, pix_y
; 
; Input
; 
;   - data_x : x_data array 
;
;   - data_y : y_data array 
;   
;   - h : header or map structure for given observation data
;
;  Output
;  
;   - pix_x : x_pixel array
;
;   - pix_y : y_pixel array

pro data2pix, data_x, data_y, h, pix_x, pix_y, $
              angle=angle, xs=xs, ys=ys  
    dtor=!dpi/180d0
    if n_elements(data_x) eq 0 or $
       n_elements(data_y) eq 0 or $
       (size(h, /type) ne 7 and $
       size(h, /type) ne 8) then begin
       message, 'Incorrect argument. (!ºoº)!', /cont
       message, 'Argument : data2pix, data_x, data_y, header or map structure, pix_x, pix_y', /cont
    endif else begin
      if size(h, /type) eq 7 then begin  ;; for header
        if strmatch(fxpar(h, 'FISSMODE'), 'Spectrograph') then begin
           cdelt1=0.16
           cdelt2=0.16
           xsize=fxpar(h, 'naxis2')
           ysize=fxpar(h, 'naxis3')
        endif else begin
           cdelt1=fxpar(h, 'CDELT1')
           cdelt2=fxpar(h, 'CDELT2')
           xsize=fxpar(h, 'naxis1')
           ysize=fxpar(h, 'naxis2')               
        endelse
        cdata_x=fxpar(h, 'tel_xpos')
        cdata_y=fxpar(h, 'tel_ypos')
        rot_ang=fxpar(h, 'rotation')*dtor
        rev=fxpar(h, 'REVERSE')
      endif else begin   ;; for map structure
        cdelt1=h.dx
        cdelt2=h.dy
        xsize=(size(h.data))[1]
        ysize=(size(h.data))[2]
        rot_ang=0.
        cdata_x=h.xc
        cdata_y=h.yc
        rev=0      
      endelse
      if keyword_set(xs) then xsize=xs
      if keyword_set(ys) then ysize=ys
      cpix_x=(xsize-1d)/2d
      cpix_y=(ysize-1d)/2d

      if n_elements(angle) ne 0 then rot_ang=angle*dtor  ;; clockwise
      dist=sqrt((data_x-cdata_x)^2.+(data_y-cdata_y)^2.)
      ang=atan(data_y-cdata_y, data_x-cdata_x)           ;; counterclockwise
      pix_x=cpix_x+dist*cos(rot_ang+ang)/cdelt1
      pix_y=cpix_y+dist*sin(rot_ang+ang)/cdelt2  
      if rev then pix_y=ysize-pix_y
    endelse
    if ~n_elements(pix_x) then begin
       pix_x=!VALUES.F_NAN
       pix_y=!VALUES.F_NAN
    endif   
;    stop
end    