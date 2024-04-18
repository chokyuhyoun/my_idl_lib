pro get_xp_yp, index, xp, yp, xxp, yyp
  xp = (findgen(index.naxis1) - index.crpix1 + 1)*index.cdelt1 + index.crval1 
  yp = (findgen(index.naxis2) - index.crpix2 + 1)*index.cdelt2 + index.crval2
  xxp = rebin(xp, n_elements(xp), n_elements(yp))
  yyp = rebin(transpose(yp), n_elements(xp), n_elements(yp))
end

