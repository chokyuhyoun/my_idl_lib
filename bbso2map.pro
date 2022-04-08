pro bbso2map,  filename, h1, map, xc=xc, yc=yc, id=id, angle=angle, $
               dx=dx, reverse=reverse, del=del
	
;xc : Image center in arcsec
;yc : Image center in arcsec
;id : Instrument name

   defsysv,'!angstrom', $             ; the Angstrom Symbol - D.Fanning
           '!6!sA!r!u!9 %!3!n'
  
  case n_params() of 

      2 : begin
          data=readfits(filename, h, /sil)
          end

      3 : begin
          data=filename
          h=h1
          end

      else : begin
      print, 'Syntax : bbso2map, filename(or data array), map, [header,]'+$
                       'xc=xc, yc=yc'
             end                      

  endcase
;  stop
    	if ~keyword_set(xc) and (fxpar(h, 'TEL_XPOS') ne 0) then $
    	    xc=fxpar(h, 'TEL_XPOS')
    	if ~keyword_set(yc) and (fxpar(h, 'TEL_YPOS') ne 0) then $
          yc=fxpar(h, 'TEL_YPOS')
    	time=fxpar(h, 'DATE-OBS')
    	if ~keyword_set(angle) then angle=fxpar(h, 'ROTATION')
      if ~keyword_set(id) then id=fxpar(h, 'wave')
      rot_data=fiss_embed(data, h, angle=angle, reverse=reverse) 
    	if ~keyword_set(dx) then dx=fxpar(h, 'cdelt1')
    	dy=dx
;    	if keyword_set(del) then rot_data=shift_sub(rot_data, -del[0], -del[1]) 
    	map=make_map(rot_data, dx=dx, dy=dy, xc=xc, yc=yc, time=time, $
    	             roll_angle=angle, id=id)
      if n_params() eq 2 then h1=map
      
     
    	
end
