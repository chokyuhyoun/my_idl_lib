function fiss_embed, data, h, angle=angle, missing=missing, reverse=reverse, $
                     side=side, del=del, _extra=extra
  case n_params() of
    1 : begin
      if ~n_elements(angle) then angle=0.
      if ~n_elements(reverse) then reverse=0.
      end
    2 : begin
      if ~n_elements(angle) then angle=fxpar(h, 'rotation')
      if ~n_elements(reverse) then reverse=fxpar(h, 'reverse')
      end
  endcase
  if ~keyword_set(missing) then missing=0.
  if ~n_elements(del) then del=[0., 0.]  ;; del : image moving direction
  if (size(data))[0] eq 3 then data=reform(data)  ;; only 2d image
  sz=double(size(data))
  if ~keyword_set(side) then side=ceil(sqrt(2.)*max(sz[1:2]))
  if (2*(side/2)) ne side then side=side+1  ; even number 
  side=double(side)
  data=float(temporary(data))
  data1=reverse ? reverse(data, 2) : data
 
  xc1=(side-1.)*0.5
  yc1=(side-1.)*0.5
  xp=(dindgen(side)#replicate(1, side))-xc1 
  yp=(replicate(1, side)#dindgen(side))-yc1    
  ang=angle*!dpi/180   ;  coordinate rotation * clockwise rotation = +  
  xp1=(xp-del[0])*cos(ang)-(yp-del[1])*sin(ang)
  yp1=(xp-del[0])*sin(ang)+(yp-del[1])*cos(ang)
  xc2=(sz[1]-1.)*0.5
  yc2=(sz[2]-1.)*0.5
  xp2=xp1+xc2  
  yp2=yp1+yc2
  rot_data=interpolate(data1, xp2, yp2, missing=missing, /double)
  return, rot_data 
end 

