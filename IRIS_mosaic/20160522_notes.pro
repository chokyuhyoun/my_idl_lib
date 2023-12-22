;iris_mosaic_maker,'2016-05-22T12:21:01.0','2016-05-23T06:11:01.0','/sanhome/schmit/genuine_mosaic/20160522/',/nodopp,force=0
cd,'/sanhome/schmit/genuine_mosaic/20160522/level2/'
f=iris_files()
;read_iris_l2,f([77,106,113,139]),a,b,wave='Si IV 1403'
read_iris_l2,f([77,106,113,139]),a,b,wave='C II 1336'
a1=a([0,64,128,192])
!p.multi=[0,4,1]
set_plot,'ps'
device,xsi=10,ysi=4,/inc,/encap,/col,bits=8,fi='../example_fuv_lev2.eps'
plot_image,b(*,*,0,0),min=-10,max=10,tit='Pointing 77, step 0',chart=2
plot_image,b(*,*,0,1),min=-10,max=10,tit='Pointing 106, step 0',chart=2
plot_image,b(*,*,0,2),min=-10,max=10,tit='Pointing 113, step 0',chart=2
plot_image,b(*,*,0,3),min=-10,max=10,tit='Pointing 139, step 0',chart=2
device,/close
set_plot,'x'

set_plot,'ps'
device,xsi=10,ysi=4,/inc,/encap,/col,bits=8,fi='../example_fuv_lev1.eps'
!p.multi=[0,4,1]
restgen,x,y,fi='../pointings/077/fuv_lev1_point.genx'
read_iris,x(0),p,q
q1=q(10:160,*)
plot_image,q1,min=100,max=120,tit='Pointing 77, step 0',chart=2
restgen,x,y,fi='../pointings/106/fuv_lev1_point.genx'
read_iris,x(0),p,q
q1=q(10:160,*)
plot_image,q1,min=100,max=120,tit='Pointing 106, step 0',chart=2
restgen,x,y,fi='../pointings/113/fuv_lev1_point.genx'
read_iris,x(0),p,q
q1=q(10:160,*)
plot_image,q1,min=100,max=120,tit='Pointing 113, step 0',chart=2
restgen,x,y,fi='../pointings/139/fuv_lev1_point.genx'
read_iris,x(0),p,q
q1=q(10:160,*)
plot_image,q1,min=100,max=120,tit='Pointing 139, step 0',chart=2
device,/close

;jun10 redo with older dark_trend
.com /archive/ssw/offline/ssw_backup/iris_dark_trend_fix.pro.20160517.171717
iris_mosaic_maker,'2016-05-22T12:21:01.0','2016-05-23T06:11:01.0','/sanhome/schmit/genuine_mosaic/20160522redo/',/nodopp,force=0

;jun14 several emails later we are somewhat certain the banding is a
;temperature related dark issue. Next question is how is wavelength
;cal effected

iris_mosaic_extract_wavecorr_edit,'20160522',result

n=size(result.times)
t1=dblarr(n(1),n(2))
.r
for i=0,n(1)-1 do begin
   for j=0,n(2)-1 do begin
      t1(i,j)=date_conv(result.times(i,j),'jul')
   endfor
endfor
end

plot,t1,
