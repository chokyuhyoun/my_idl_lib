pro get_xp_yp, index, xp, yp, xxp, yyp, data=data
  if total(tag_names(index) eq 'DATA') and $
     total(tag_names(index) eq 'XC') and $
     total(tag_names(index) eq 'YC') and $
     total(tag_names(index) eq 'DX') and $
     total(tag_names(index) eq 'DY') then begin
     sz = size(index.data) 
     xp = (findgen(sz[1]) - 0.5*(sz[1] - 1))*index.dx + index.xc
     yp = (findgen(sz[2]) - 0.5*(sz[2] - 1))*index.dy + index.yc
  endif else begin
    if total(tag_names(index) eq 'crota2') then begin
      if abs(index.crota2 - 180.) lt 1 then begin
        data = rotate(temporary(data), 2)
        index.crpix1 = index.naxis1 - index.crpix1 + 1
        index.crpix2 = index.naxis2 - index.crpix2 + 1
        index.crota2 = 0.
      endif
    endif  
    xp = (findgen(index.naxis1) - index.crpix1 + 1)*index.cdelt1 + index.crval1 
    yp = (findgen(index.naxis2) - index.crpix2 + 1)*index.cdelt2 + index.crval2
  endelse  
  xxp = rebin(xp, n_elements(xp), n_elements(yp))
  yyp = rebin(transpose(yp), n_elements(xp), n_elements(yp))
end

