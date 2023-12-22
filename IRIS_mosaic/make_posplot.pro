pro make_posplot,dir
  cd,dir
  restgen,fi='lev1_drms.genx',a,b
  set_plot,'ps'
  device,xsi=8,ysi=8,/inc,/enca,/col,bits=8,file='lev1.eps'
  str=strmid(a.instrume,0,1)
  n=size(str)
  wh=(str eq 'F')+2*(str eq 'S')
  col=indgen(256)#(fltarr(3)+1)
  col(1,*)=[255,0,0]
  col(2,*)=[0,0,255]
  tvlct,col
  plot,/nodat,[-1100,1100],[-1100,1100],xtit='X pos',ytit='Y pos', tit='Lev 1 HDR Positions Black-NUV, Red-FUV, Blue-SJI'
  plots,a(*).xcen,a(*).ycen,psym=1,col=wh
  device,/close
  files=file_list('level2/','*.fits')
  n=size(files)
  device,xsi=8,ysi=8,/inc,/enca,/col,bits=8,file='lev2.eps'
  plot,/nodat,[-1100,1100],[-1100,1100],xtit='X pos',ytit='Y pos', tit='Lev 2 HDR'
  for i=0,n(1)-1 do begin
     b=iris_obj(files(i))
     x=b->getxpos()
     xs=n_elements(x)
     y=b->getypos()
     ys=n_elements(y)
     plots,x,replicate(y(ys/2),xs),psym=1
  endfor
  device,/close
  set_plot,'x'
end

  
