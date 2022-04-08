
; Name : fiss_data2pix
;
; Object : convert FISS data coordinate to pixel position
;
; Colling sequence : fiss_data2pix, data_x, data_y, h, pix_x, pix_y
; 
; Input
; 
;   - data_x : x_data array 
;
;   - data_y : y_data array 
;   
;   - h : fiss_header
;
;  Output
;  
;   - pix_x : x_pixel array
;
;   - pix_y : y_pixel array

pro fiss_data2pix, data_x, data_y, h, pix_x, pix_y
    dtor=!dpi/180d0
    if n_elements(data_x) eq 0 or $
       n_elements(data_y) eq 0 or $
       size(h, /type) ne 7 then begin
       message, 'Incorrect argument. (!ºoº)!', /cont
       message, 'Argument : data2pix, data_x, data_y, header, pix_x, pix_y', /cont
    endif else begin
       cdelt1=0.16
       cdelt2=0.16
       xsize=fxpar(h, 'naxis2')
       ysize=fxpar(h, 'naxis3')
       cpix_x=(xsize-1d)/2d
       cpix_y=(ysize-1d)/2d
       cdata_x=fxpar(h, 'tel_xpos')
       cdata_y=fxpar(h, 'tel_ypos')
       rot_ang=fxpar(h, 'rotation')*dtor
       dist=sqrt((data_x-cdata_x)^2.+(data_y-cdata_y)^2.)
       ang=atan(data_y-cdata_y, data_x-cdata_x)
       pix_x=cpix_x+dist*cos(ang+rot_ang)/cdelt1
       pix_y=cpix_y+dist*sin(ang+rot_ang)/cdelt2
       if fxpar(h, 'REVERSE') then pix_y=ysize-pix_y
    endelse
    if total(pix_x gt xsize) ne 0 or $
       total(pix_x lt 0.) ne 0 or $
       total(pix_y gt ysize) ne 0 or $
       total(pix_y lt 0.) ne 0 then message, 'Result is in outside of the data. (!ºoº)!' 
       
;    stop
end    