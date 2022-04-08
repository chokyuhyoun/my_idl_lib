function fiss_read_pca, file, h
  h=headfits(file, /sil)
  h=fxpar(h, 'comment')
  ;  if h[0] eq 0 then h=headfits(file, /sil)
  nwv=fxpar(h, 'NAXIS1')
  nslit=fxpar(h, 'NAXIS2')
  nstep=fxpar(h, 'NAXIS3')
  data=fltarr(nwv, nslit, nstep)
  for i=0, nstep-1 do begin
    data[*, *, i]=fiss_read_frame(file, i, /pca)
  endfor
  ;  stop
  return, data
end