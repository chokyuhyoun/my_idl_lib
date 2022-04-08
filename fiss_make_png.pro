; Name : fiss_make_png
;
; Purpose : Make png file 
;
; Input : PCA Compressed FISS datafiles 
;
; Output : png file which is changed the filename extension (fts -> png)
;
; Option
;   - wv : wavelength (n by 2 array)
;            [[ X, X, X], <-- for Ha
;             [ X, X, X]] <-- for Ca II 8542A
;          default :  -1, -0.5, -0.3, 0, 0.3, 0.5, 1   Augstrum in Ha,
;                   -0.5, -0.3, -0.1, 0, 0.1, 0.3, 0.5 Augstrum in CaII 8542             
;   - subdir : subdirectory to save the image files      
;              directory or [for Ha, for CaII]       

pro fiss_make_png, f, wave=wave, subdir=subdir  

cd, current=c                         
for i=0, n_elements(f)-1 do begin
    if strmatch(f[i], '*_p.fts') eq 0 then begin
        if strmatch(f[i], '*_A1_*') eq 1 then begin       ;if file is Ha image
           if n_elements(wave) eq 0 then wv=[-1, -0.5, -0.3, 0, 0.3,  0.5, 1] $
                                    else wv=wave[*, 0]
           loadct, 3, /sil
        endif else begin                                  ;if file is Ca image
           if n_elements(wave) eq 0 then wv=[-0.5, -0.3, -0.1, 0, 0.1, 0.3, 0.5] $
                                    else wv=wave[*, 1]
           loadct, 8, /sil
        endelse
        raster=fiss_raster(f[i], wv, 0.05)
        size=size(raster)
        window, 0, xs=size[1]*size[3], ys=size[2]
        for j=0, n_elements(wv)-1 do begin
            if (where(finite(raster[*,*,j], /nan)))[0] ne -1 then $
               raster[*,*,j]=fltarr(size[1], size[2])  
            ex=raster[*,*,j]
            if n_elements(where(ex gt 50.)) le 100 then exam=ex $
                                            else exam=ex(where(ex gt 50.))
            tv, bytscl(ex, min=median(exam)-3.*stddev(exam),  $
                           max=median(exam)+3.*stddev(exam)), j
            xyouts, size[1]*j+10, size[2]-20, string(wv[j], format='(f4.1)'), $
                    color=255, /device
        endfor
        xyouts, 20, 20, strmid(f[i], 5, 8+6+1), color=255, /device  
        dotpos=strpos(f[i], '.', /reverse_search)
        if n_elements(subdir) ne 0 then begin
           cd, current=c
           if strmatch(f[i], '*_A1_*') eq 1 then d=subdir[0] $
                                            else d=subdir[n_elements(subdir)-1]
           file_mkdir, d
           cd, d
        endif
        write_png, strcompress(strmid(f[i], 0, dotpos+1)+'png'), tvrd(/true)
        cd, c
        print, string(float(i+1.)/n_elements(f)*100., format='(f5.1)')+'%'
     endif
 endfor 

if n_elements(f) eq 0 then print, 'Incorrect files'$
                      else wdelete
loadct, 0, /sil
;stop
end        
