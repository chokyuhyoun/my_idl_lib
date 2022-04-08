
; Name : fiss_pix2data
;
; Object : convert pixel position to data coordinate
;
; Colling sequence : pix2data, pix_x, pix_y, header, data_x, data_y
;
; Input
; 
;   - pix_x : x_pixel array
;   
;   - pix_y : y_pixel array
;      
;   - map : fiss_header
;
;  Output
;  
;   - data_x : x_data array
;   
;   - data_y : y_data array
   
pro fiss_pix2data, pix_x, pix_y, h, data_x, data_y
   dtor=!dpi/180d0
   if n_elements(pix_x) eq 0 or $
      n_elements(pix_y) eq 0 or $
      size(h, /type) ne 7 then begin
      message, 'Incorrect argument. (!ºoº)!', /cont
      message, 'Argument : pix2data, pix_x, pix_y, header, data_x, data_y', /cont
   endif else begin   
      cdelt1=0.16
      cdelt2=0.16
      xsize=fxpar(h, 'NAXIS2')
      ysize=fxpar(h, 'NAXIS3')
      if fxpar(h, 'REVERSE') then pix_y=ysize-pix_y
      cpix_x=(xsize-1d)/2d
      cpix_y=(ysize-1d)/2d
      cdata_x=fxpar(h, 'tel_xpos')
      cdata_y=fxpar(h, 'tel_ypos')
      rot_ang=fxpar(h, 'rotation')*dtor
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
