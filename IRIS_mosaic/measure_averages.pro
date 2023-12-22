pro measure_averages,dir
  cd,dir
  files=file_list('level2/','*.fits')
  n=n_elements(files)
  times=strarr(n,64)
  bri=fltarr(n,64)
  for i=0, n-1 do begin
     read_iris_l2,files(i),a,b,wave='Mg II k 2796',/silent
     bri(i,*)=a.tdp90_7
     times(i,*)=a.date_obs
     std=stddev(a.datap90)
     m=median(a.datap90)
     !p.multi=[0,8,8]
     !x.margin=[0,0]
     !y.margin=[0,0]
     str=replicate(" ",50)
  ;   for j=0,63 do begin
   ;     plot_image, b(*,*,j),max=150*(max(b(*,*,j)) gt 200)+50,min=0,xtickn=str,ytickn=str,/nosq
    ;    xyouts,20,25,string(f='(i2.2)',j),col=128
    ; endfor
     ;print,i
     ;pause
     
  endfor

  stop
end
