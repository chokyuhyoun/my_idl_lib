;  Name : fiss_wv_image
;
;  Purpose : make images for each wavelength
;
;  Calling Sequence : fiss_wv_image, f_list
;
;  Input
;   - f_list : FISS filelist to make images
;   
;  Output : image files in the subdir(name = observed time + waveband)
;   
    
pro fiss_wv_image, f_list

for list=0, n_elements(f_list)-1 do begin
    f=f_list[list]
    data=readfits(f, h, /sil)
    window, 0, xs=(size(data))[2], ys=(size(data))[3]
    h_alpha=strmatch(sxpar(h, 'WAVELEN'), '6562*')
    if h_alpha eq 1 then loadct, 3, /sil else loadct, 8, /sil
    date=sxpar(h, 'DATE')
    subdir=strcompress(strmid(date, 11, 2)+'_'+strmid(date, 14, 2)+'_'+$
                       strmid(date, 17, 2)+'_'+sxpar(h, 'WAVELEN'), /remove_all)
    file_mkdir, subdir
    cd, subdir                   
    for i=0, (size(data))[1]-1 do begin
        ex=data[i,*,*]
        if n_elements(where(ex gt 50.)) le 100 then exam=ex $
                                        else exam=ex(where(ex gt 50.))
        tv, bytscl(ex, min=((median(exam)-3.*stddev(exam))>0),  $
                       max=median(exam)+3.*stddev(exam))
;        tvscl, data[i, *, *]
        xyouts, 0.05, 0.9, strcompress(string((i-fxpar(h, 'CRPIX1'))*fxpar(h, 'CDELT1'), $
                                             format='(f5.2)')+!angstrom), color=255, $
                                             charsize=2, /normal
        xyouts, 0.05, 0.05, string(fxpar(h, 'ENDTIME')), color=255, charsize=2, /normal                                         
    ;stop
        if fxpar(h, 'CDELT1') gt 0 then begin 
           write_png, strcompress(string(i)+'.png', /remove_all), tvrd(/true)
        endif else begin
           write_png, strcompress(string((size(data))[1]-1-i)+'.png', /remove_all), tvrd(/true)
        endelse
    endfor
    cd, '..'
endfor        
wdelete
loadct, 0, /sil
end