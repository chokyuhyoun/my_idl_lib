
;+
; :Description:
;    Describe the procedure.
;
; :Params:
;    filename
;    h1
;    map
;
; :Keywords:
;    wv
;    xc
;    yc
;
; :Author: chokh
;-
pro fiss2map, filename, h1, map, wv=wv, xc=xc, yc=yc, angle=angle, reverse=reverse, $
              _extra=extra  
;wv : wavelength which you want. (0 = center)
;xc : Image center in arcsec
;yc : Image center in arcsec
   
   if !version.os_family eq 'Windows' then $
   defsysv, '!angstrom', '!3!sA!r!u!9 %!3!n' else $
   defsysv, '!angstrom', string(byte("305b))
   defsysv, '!alpha', '!4a!3'                    ; Alpha symbol             
    
  case n_params() of 

      2 : begin
          if strmatch(filename, '*_c*') then pca=1 else pca=0
          if pca then begin
            data=fiss_read_pca(filename, h)
          endif else begin
            data=readfits(filename, h, /sil)
          endelse
          end

      3 : begin
          data=filename
          h=h1
          end

      else : begin
      print, 'Syntax : fiss2map_n, filename(or data array), map, [header,], wv=wv'
             end                      

  endcase
;  stop
      if ~keyword_set(xc) then xc=fxpar(h, 'TEL_XPOS')
      if ~keyword_set(yc) then yc=fxpar(h, 'TEL_YPOS')
      if ~keyword_set(angle) then angle=fxpar(h, 'rotation')
      if ~keyword_set(reverse) then reverse=fxpar(h, 'REVERSE')
      if ~keyword_set(wv) then begin
         px=fxpar(h, 'CRPIX1')
         wv=0
      endif else begin
         px=fiss_wv2pix(h, wv)>0<(fxpar(h, 'naxis1')-1)
      endelse
      if fxpar(h, 'CRVAL1') eq 6562.8170d then begin
          id='FISS H'+!alpha $
               +strcompress(string(wv, format='(f+5.2)'), /remove_all)+!angstrom $
               +' '
      endif else begin
          id='FISS Ca II 8542' $
               +strcompress(string(wv, format='(f+5.2)')+!angstrom, /remove_all) $
               +' '
      endelse
      time=fxpar(h, 'DATE')
      if (size(data))[0] eq 3 then data=reform(data[px, *, *]) 
      rot_data=fiss_embed(data, h, angle=angle, reverse=reverse, _extra=extra)               
      map=make_map(rot_data, dx=0.16, dy=0.16, xc=xc, yc=yc, time=time, $
                   roll_angle=angle, id=id)
      map=create_struct(map, 'exptime', fxpar(h, 'EXPTIME'))
      map.time=strmid(map.time, 0, strlen(map.time)-4)
      if n_params() eq 2 then h1=map
;     stop             
end
