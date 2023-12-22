cd,'/sanhome/schmit/genuine_mosaic/20150927/'
  restgen,a,b,c,'IRISMosaic_20150927_MgIIh.genx'
  restgen,a1,a2,a3,a4,a5,a6,a7,a8,a9,fi='IRISMosaic_20150927_MgIIh.genx'
  print,a8([160,850],5200)      ;timestamp but not clear how zeroed
  print,tai2utc(a8(160,5200),/ext) ;its tai time
  tot=total(a1<1000>0,3)
  plot_image,tot,min=1500,max=8000,/nosq
  x=590 & y=3340 ;mixed plage segment
  plot,findgen(201)-100,a8(x-100:x+100,y),/xsty,/ysty
  plot, findgen(601)-300,a9(x,y-300:y+300),/xsty,/ysty
  print,tai2utc(a8(x,y),/ext)
  print, a9(x,y)
  f=file_list('level2','*.fits')
  idx=where(strpos(f,'204741') gt 0)
  read_iris_l2,f(idx),mghd,mgdt,wave='Mg II k 2796'
  a=iris_obj(f(idx))
  wvl2=a->getlam(6)
  mn=min(where(wvl2 gt a5(0)))-1
  mx=max(where(wvl2 lt a5(n_elements(a5)-1)))+1
  print,transpose([[string(indgen(64))],[ mghd.date_obs]])
  !p.multi=[0,2,1]
  plot_image,mgdt(mn:mx,0:500,37),min=0,max=400,/nosq
  plot_image,transpose(reform(a1(x,y-a9(x,y):y+500-a9(x,y),*))),min=0,max=400,/nosq

  clearplot
  tvlct,col,/get
  col(1,*)=[255,0,0]
  tvlct,col
n=size(a1)
  plot,psym=4,total(a1(x,y-a9(x,y):y+500-a9(x,y),*),3)/n(3)*(a5(n(3)-1)-a5(0)),/yno,thi=2
oplot,total(mgdt(mn:mx,0:500,37),1)/(mx-mn+1)*(wvl2(mx)-wvl2(mn)),psym=1,col=1               
  plot,psym=4,total(a1(x,y-a9(x,y):y+500-a9(x,y),*),3),/yno,thi=2
oplot,total(mgdt(mn:mx,0:500,37),1),psym=1,col=1               

mreadfits,'/sanhome/schmit/genuine_mosaic/20150927/IRISMosaic_20150927_MgIIh.fits',hdr,img
