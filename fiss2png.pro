; Name : fiss2png
;
; Purpose : Make png file 
;
; Input : PCA Compressed FISS datafiles 
;
; Output : png file(Ha + CaII image for each wavelength) 
;          changed the filename extension (fts -> png)
;
; Option
;   - wv : wavelength (n by 2 array)
;            [[ X, X, X], <-- for Ha
;             [ X, X, X]] <-- for Ca II 8542A
;          default :  -4,   -1, -0.5, 0, 0.5,   1   Augstrom in Ha,
;                     -5, -0.8, -0.2, 0, 0.2, 0.8   Augstrom in CaII 8542             
;   - subdir : subdirectory to save the image files      
      

pro fiss2png, f, wave=wave, subdir=subdir, percent=percent, pca=pca 

!p.font=1
!p.charsize=3.
!p.charthick=3.
                      
cd, current=c
if n_elements(subdir) eq 0 then begin
  save_dir=strcompress(c+path_sep()+'fiss_snap', /remove_all)
endif else begin
  save_dir=subdir
endelse
file_mkdir, save_dir
  
if keyword_set(pca) then begin
    ha_file=f[where(strmatch(f, '*A1_c*') eq 1, /null)]
    ca_file=f[where(strmatch(f, '*B1_c*') eq 1, /null)]
endif else begin
    ha_file=f[where(strmatch(f, '*A1*') eq 1, /null)]
    ca_file=f[where(strmatch(f, '*B1*') eq 1, /null)]
endelse    
if n_elements(ha_file) eq 0 then begin
    print, 'Incorrect files'
    goto, finish
endif
    
ha_jultime=fiss_jultime(ha_file)
ca_jultime=fiss_jultime(ca_file)
;stop                      
for i=0, n_elements(ha_file)-1 do begin
    
    if n_elements(wave) eq 0 then begin
        ha_wv=[-4,   -1, -0.5, 0, 0.5,   1]
        ca_wv=[-5, -0.8, -0.2, 0, 0.2, 0.8]
    endif else begin
        ha_wv=wave[*, 0]
        ca_wv=wave[*, 1]
        if n_elements(ha_wv) ne n_elements(ca_wv) then begin
            print, 'Number of Ha and Ca II files do not match'
        endif
    endelse

    if keyword_set(pca) then begin
        ha_raster=fiss_raster(ha_file[i], ha_wv, 0.05)
    endif else begin
        ha_data=readfits(ha_file[i], h_ha, /sil)
        ha_wv_pix=fiss_wv2pix(h_ha, ha_wv)
        ha_raster=ha_data[ha_wv_pix, *, *]
        ha_raster=transpose(ha_raster, [2, 1, 0])
    endelse    
    ha_size=size(ha_raster)
    match=(where(abs(ha_jultime[i]-ca_jultime) eq $
             min(abs(ha_jultime[i]-ca_jultime))))[0]
    if abs(ha_jultime[i]-ca_jultime[match])*86400d gt 5d then begin
        no_data=1
    endif else begin
        no_data=0
        if keyword_set(pca) then begin
            ca_raster=fiss_raster(ca_file[match], ca_wv, 0.05)
        endif else begin
            ca_data=readfits(ca_file[match], h_ca, /sil)
            ca_wv_pix=fiss_wv2pix(h_ca, ca_wv)
            ca_raster=ca_data[ca_wv_pix, *, *]    
            ca_raster=transpose(ca_raster, [2, 1, 0])        
        endelse        
    endelse
    ca_size=ha_size
    ca_size[2]=250
;    stop
    window, 0, xs=ha_size[1]*ha_size[3], ys=ha_size[2]+ca_size[2], /pixmap
    loadct_ch, /ha
    for j=0, n_elements(ha_wv)-1 do begin
        if (where(finite(ha_raster[*,*,j], /nan)))[0] ne -1 then $
           ha_raster[*,*,j]=fltarr(ha_size[1], ha_size[2])  
        ex=ha_raster[*,*,j]
        if n_elements(where(ex gt 50.)) le 100 then exam=ex $
                                        else exam=ex(where(ex gt 50.))
        tv, bytscl(ex, min=((median(exam)-3.*stddev(exam))>0),  $
                       max=median(exam)+3.*stddev(exam)), j
        xyouts, ha_size[1]*j+10, ha_size[2]+ca_size[2]-20, $
                string(ha_wv[j], format='(f4.1)'), color=255, /device
        xyouts, 20, ca_size[2]+20, strmid(ha_file[i], 0, strlen(ha_file[i])-4),$
                color=255, /device
    endfor
    if no_data then begin
        xyouts, 20, 20, 'No data', /device
    endif else begin
        loadct_ch, /ca
        for k=0, n_elements(ca_wv)-1 do begin
            if (where(finite(ca_raster[*,*,k], /nan)))[0] ne -1 then $
               ca_raster[*,*,k]=fltarr(ca_size[1], ca_size[2])  
            ex=fltarr(ca_size[1], ha_size[2])
            ex[*, ha_size[2]-ca_size[2]:ha_size[2]-1]=reform(ca_raster[*,*,k])
            
            if n_elements(where(ex gt 50.)) le 100 then exam=ex $
                                            else exam=ex(where(ex gt 50.))
            tv, bytscl(ex, min=median(exam)-3.*stddev(exam),  $
                           max=median(exam)+3.*stddev(exam)), $
                n_elements(ha_wv)+k
            xyouts, ca_size[1]*k+10, ca_size[2]-20, $
                    string(ca_wv[k], format='(f4.1)'), color=255, /device
            xyouts, 20, 20, strmid(ca_file[match], 0, strlen(ca_file[match])-4), $
                    color=255, /device                
        endfor    
    endelse
    grat=fxpar(h_ha, 'gratwvln')
    if abs(grat-6562.) lt 10. then set='Set 1' else $
    if abs(grat-5889.) lt 10. then set='Set 2' else set=''
    xyouts, ca_size[1]*n_elements(ca_wv)-100, 20, set, /device, color=255
;    stop
    
    cd, save_dir
    write_png, strcompress(strmid(ha_file[i], 5, 8+6+1)+'.png'), tvrd(/true)
    cd, c
    if keyword_set(percent) then begin
        print, string(float(i+1.)/n_elements(ha_file)*100., format='(f5.1)')+'%'
    endif
;    stop
endfor 
;stop
loadct, 0, /sil
finish :
end        


main_path='/data/fiss/2018/10'
cd, main_path
f=file_search(main_path, 'proc', /test_directory, /fully)
dir=strsplit(f, path_sep(), /extract)
yymmdd=strarr(n_elements(f))
for i=0, n_elements(f)-1 do begin
  yymmdd[i]=strmid(dir[i, 2], 2, 2)+dir[i, 3]+dir[i, 4]
endfor
stop
for i=0, n_elements(f)-1 do begin
;for i=7, 8 do begin 
  cd, f[i]
  obj=file_search(/test_dir)
  obj=obj[where(obj ne 'cal')]
  for j=0, n_elements(obj)-1 do begin
    cd, f[i]+path_sep()+obj[j]
    tar = file_search(/test_dir)
    for k=0, n_elements(tar)-1 do begin
      cd, f[i]+path_sep()+obj[j]+path_sep()+tar[k]
      save_dir='/data/home/chokh/fiss/'+yymmdd[i]+path_sep()+obj[j]+path_sep()+tar[k]
      fissfile=file_search('*.fts')
      fiss2png, fissfile, subdir=save_dir
    endfor
  endfor
endfor  

end




