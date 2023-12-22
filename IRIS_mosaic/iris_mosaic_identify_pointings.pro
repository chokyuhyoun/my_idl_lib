pro IRIS_MOSAIC_IDENTIFY_POINTINGS, home_dir = home_dir, $
	verbose = verbose, remote = remote

  if N_ELEMENTS(home_dir) eq 0 then home_dir = './'
  verbose = KEYWORD_SET(verbose)
  remote = KEYWORD_SET(remote)
;THOSE KEYWORDS DONT YET DO ANYTHING  

  RESTGEN, file = CONCAT_DIR(home_dir, 'lev1_drms.genx'), drms, fl
  
  nfiles = N_ELEMENTS(fl)
  pointkey = INTARR(nfiles) - 1



;
;fl=iris_time2files('2015/08/23T12:23:01','2015/08/24T06:51:10',drms,/jsoc,key='ISQFLTDX,ISQFLTNX,ISQOLTID,IWM1CTGT,IWM2CTGT,ISQOLTDX,ISQOLTNX')

;NEED TO UPDATE THE ORIGINAL IRIS_TIME2FILES TO OUTPUT ABOVE KEYWORDS
;ALSO GET RID OF CALL TO RESTORE POINTKEY FOR MAKEL2
pobs=uniq(drms.isqoltid)        ;this eliminates primer frames and non-existant from the LEVEL 1 dbase
nobs=n_elements(pobs)
frobs=lonarr(nobs)
for i=0,nobs-1 do frobs(i)=total(drms.isqoltid eq drms(pobs(i)).isqoltid)
tmp=max(frobs,qobs)
d=where((drms.isqoltid eq drms(pobs(qobs)).isqoltid)*file_test(fl))
fl=fl(d)
drms=drms(d)


n=size(fl)
jd=dblarr(n(1))
for i=0l,n(1)-1 do jd(i)=date_conv(drms(i).t_obs,'julian')

pt=string(f='(i3.3)',drms.iwm1ctgt)+string(f='(i3.3)',drms.iwm2ctgt)
; to use uniq i have to sort pt but then must resort into time
spti=uniq(pt,sort(pt))
rsrt=sort(spti)
pti=pt(spti(rsrt))
ptn=n_elements(pti)
maxcnt=drms(0).isqfltnx*drms(0).isqoltnx*drms(0).iiflnrpt     ;RPT handle obs 3881608195

times=dblarr(ptn,2)
for i=0,ptn-1 do begin
   c1=where((drms.instrume eq 'FUV')*(pt eq pti(i)))
   c2=where((drms.instrume eq 'NUV')*(pt eq pti(i)))
   c3=where((drms.instrume eq 'SJI')*(pt eq pti(i)))

   if(n_elements(c1) gt maxcnt) then begin ;remove extra files
      xfr=n_elements(c1)-maxcnt
      t2=median(jd(c1))
      tr=c1(reverse(sort(abs(t2-jd(c1)))))
      c1=cmset_op(c1,'xor',tr(0:xfr-1))
   endif
    if(n_elements(c2) gt maxcnt) then begin ;remove extra files
      xfr=n_elements(c2)-maxcnt
      t2=median(jd(c2))
      tr=c2(reverse(sort(abs(t2-jd(c2)))))
      c2=cmset_op(c2,'xor',tr(0:xfr-1))
   endif
    if(i gt 0) then begin
       b1=where(jd(c1) lt times(i-1,1))
       if(b1(0) ne -1) then c1=cmset_op(c1,'xor',c1(b1))
       b2=where(jd(c2) lt times(i-1,1))
       if(b2(0) ne -1) then c2=cmset_op(c2,'xor',c2(b2))
       b3=where(jd(c3) lt times(i-1,1))
       if(b3(0) ne -1) then c3=cmset_op(c3,'xor',c3(b3))
    endif       
          
    if(c1(0) ne -1) then begin
       fuvd=drms(c1)
       fuvf=fl(c1)
    endif else begin
       fuvd=[]
       fuvf=[]
    endelse
    if(c2(0) ne -1) then begin
       nuvd=drms(c2)
       nuvf=fl(c2)
    endif else begin
       nuvf=[]
       nuvd=[]
    endelse
    if(c3(0) ne -1) then begin
       sjid=drms(c3)
       sjif=fl(c3)
    endif else begin
       sjid=[]
       sjif=[]
    endelse
    cmb=[c1,c2,c3]
    cmb=cmb(where(cmb ne -1))
     times(i,*)=minmax(jd(cmb))
   print, 'post',i, n_elements(fuvf),n_elements(nuvf),n_elements(sjif),times(i,0)-jd(0),times(i,1)-jd(0)

   dir = CONCAT_DIR(home_dir, 'pointings/' + STRING(i, form = '(i03)'))
   if not FILE_EXIST(dir) then SPAWN, 'mkdir ' + dir, result, errcode

   SAVEGEN, file = CONCAT_DIR(dir, 'fuv_lev1_point.genx'), $
            fuvf, fuvd, names = ['pointfiles', 'banddrms']
   SAVEGEN, file = CONCAT_DIR(dir, 'nuv_lev1_point.genx'), $
            nuvf, nuvd, names = ['pointfiles', 'banddrms']
   SAVEGEN, file = CONCAT_DIR(dir, 'sji_lev1_point.genx'), $
            sjif, sjid, names = ['pointfiles', 'banddrms']
   
 
endfor
            
      
end


   
