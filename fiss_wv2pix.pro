;Name : fiss_wv2pix
;
;Purpose : Conversion from wavelength to pixel using the plot_map
;
;Calling sequence : pix=fiss_wv2pix(h, wv)
;
;Input
;  - wv : wavelength
;  - h : header


function fiss_wv2pix, h, wv
   if n_elements(wv) eq 0 or n_elements(h) eq 0 then begin
      print, 'Incorrect argument. Calling sequence : pix=fiss_wv2pix(h, wv)'
      return, -1
   endif
   pix=fxpar(h, 'CRPIX1')+wv/fxpar(h, 'CDELT1')
   return, pix
end   