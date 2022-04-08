function fiss_pix2wv, pix, h
   if n_elements(pix) eq 0 or $
      n_elements(h) eq 0 then begin
      print, 'Incorrect argument'
      print, 'Argument : wave=fiss_pix2wv(pix, header)
      return, -1
   endif else begin
      wv=(pix-fxpar(h, 'CRPIX1'))*fxpar(h, 'CDELT1')
      return, wv
   endelse   
end   