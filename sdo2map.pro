pro sdo2map, file_name, mapstruct, index, sdoim, _extra=_extra
  if total(strmatch(file_name, '*fits')) ne n_elements(file_name) then begin
      print, 'Please check the SDO files'
      stop
  endif else begin
  
	read_sdo, file_name, index, sdoim, _extra=_extra
	index2map, index, sdoim, mapstruct
	if total(strmatch(tag_names(index), 'LVL_NUM')) eq 0 then $
	   index=create_struct(index, 'LVL_NUM', 1)
	if (strmatch(file_name, '*hmi*') eq 1) and $
	   (index[0].lvl_num eq 1) and $
	   (strmatch(file_name, '*sharp*', /fold_case) ne 1) then begin
	   mapstruct.data=rotate(temporary(mapstruct.data), 2)
	   index.crpix1=index.naxis1-index.crpix1+1
	   index.crpix2=index.naxis2-index.crpix1+1
	   index.crota2=index.crota2-180
	   mapstruct.xc=-mapstruct.xc
	   mapstruct.yc=-mapstruct.yc
	   mapstruct.roll_angle=mapstruct.roll_angle-180
	endif
	endelse
	xp = (findgen(index.naxis1)-(index.crpix1-1))*index.cdelt1
	yp = (findgen(index.naxis2)-(index.crpix2-1))*index.cdelt2
	mapstruct = create_struct(mapstruct, 'xp', xp, 'yp', yp)
;	stop
end