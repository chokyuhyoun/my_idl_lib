pro fiss_inst_shift_cor, pre_dop, del2, angle, h, result, pre_res=pre_res, $
                         pattern=pattern, side=side, _extra=extra
;  dum=fiss_embed(reform(pre_dop[*, *, 0]), h, _extra=extra)
;  sz=size(dum)
  result=fltarr(side, side, n_elements(angle))
  sz1=size(pre_dop)
  pre_res=pre_dop
  pre_res[*]=0.
  pattern=pre_res
  xp=findgen(sz1[1])#replicate(1., sz1[2])
  yp=replicate(1., sz1[1])#findgen(sz1[2])
  ang=angle*!dtor
  xp1=xp-0.5*(sz1[1]-1)
  yp1=yp-0.5*(sz1[2]-1)
  dop_i=pre_dop
  mean_dop=fltarr(sz1[1], sz1[2])
  
  for i=0, n_elements(angle)-1 do begin
;    i=43
    dop_i[*]=!values.f_nan
    mean_dop[*]=!values.f_nan
    for j=0, n_elements(angle)-1 do begin
      if i eq j then begin 
        dop_i[*, *, j]=pre_dop[*, *, i]
      endif else begin
        xpp=xp1*cos(ang[i])+yp1*sin(ang[i])
        ypp=-xp1*sin(ang[i])+yp1*cos(ang[i])
        xpp=xpp-del2[0, j]+del2[0, i]
        ypp=ypp-del2[1, j]+del2[1, i]
        xp2=xpp*cos(ang[j])-ypp*sin(ang[j])+0.5*(sz1[1]-1)
        yp2=xpp*sin(ang[j])+ypp*cos(ang[j])+0.5*(sz1[2]-1)
        dop_i[*, *, j]=interpolate(pre_dop[*, *, j], xp2, yp2, missing=!values.f_nan)
;        stop
      endelse
;;----- position test
;      tv, bytscl(dop_i[*, *, j], 2d3, 5d3)
;      wait, 0.05
    endfor
    mean_dop=mean(dop_i, dim=3, /nan)
    
;    pattern[*, *, i]=replicate(1., sz1[1])#reform(median(pre_dop[*, *, i]-mean_dop, dim=1))
    pat=mean(pre_dop[*, *, i]-mean_dop, dim=1, /nan)
    pattern[*, *, i]=rebin(transpose(pat), sz1[1], sz1[2])
    pre_res[*, *, i]=pre_dop[*, *, i]-pattern[*, *, i]
    result[*, *, i]=fiss_embed(pre_res[*, *, i], h, angle=angle[i], $
                               missing=!values.f_nan, side=side, $
                               _extra=extra, del=del2[*, i])
;    stop
  endfor
end


;; position test
if 0 then begin
window, 0
cd, 'C:\Users\chokh\Desktop\20150618\fiss
if 0 then begin
f=file_search('*A1_c.fts')
sz=size(fiss_raster(f[0], -4, 0.02))
rasters=fltarr(sz[1], sz[2], n_elements(f))
for i=0, n_elements(f)-1 do begin
  print, i
  rasters[*, *, i]=fiss_raster(f[i], -4, 0.02)
endfor
rasters=transpose(rasters, [1, 0, 2])
save, rasters, filename='fiss_cont_img.sav'
endif 
restore, 'fiss_cont_img.sav'

cd, 'align'
restore, 'fiss_align_info2.sav'
f1=file_search('*A1_align.fts')
h=headfits(f1[0])
print, 'done'
fiss_inst_shift_cor, fiss_cont_img, a_del, fiss_angle, h, result
endif 

end

