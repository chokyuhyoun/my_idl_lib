pro tv_rgb_trans, image, alpha, position=p,_extra=extra
  sz=size(image)
  if sz[0] ne 3 then message, 'Invalid truecolor image' 
  image=bytscl(temporary(image))
  truetype=max(where(sz eq 3))
  if truetype ne 3 then begin
    image=transpose(temporary(image), [where(sz[1:3] ne 3), truetype])
    truetype=3
  endif
  if ~keyword_set(p) then begin
    back=tvrd(true=3)
    temp=(1.-alpha)*temporary(back)+alpha*temporary(image)
  endif else begin
    temp=tvrd(true=3)
    x_start=p[0]*!d.x_vsize
    y_start=p[1]*!d.y_vsize
    x_size=(p[2]-p[0])*!d.x_vsize
    y_size=(p[3]-p[1])*!d.y_vsize
    fore1=congrid(image, x_size, y_size, 3)
    back1=temp[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *]
    temp1=(1.-alpha)*temporary(back1)+alpha*temporary(fore1)
    temp[x_start:x_start+x_size-1, y_start:y_start+y_size-1, *]=temp1
  endelse
  tv,byte(temporary(temp)),true=3
;  stop
end




;if (size(image))[0] ne 3 then message, 'Invalid truecolor image'
;image=bytscl(image)
;truetype=max(where(size(image) eq 3))
;cur_win=!d.window
;back=tvrd(true=3)
;window,/free,xsize=!d.x_size,ysize=!d.y_size,/pix
;pix_win=!d.window
;wset,pix_win
;device,copy=[0,0,!d.x_size,!d.y_size,0,0,cur_win]
;plot_image, image, true=truetype, xstyle=5, ystyle=5, position=position, _extra=extra
;fore=tvrd(true=3)
;wdelete,pix_win
;wset,cur_win
;temp=(1.-alpha)*temporary(back)+alpha*temporary(fore)
;tv,byte(temporary(temp)),true=3