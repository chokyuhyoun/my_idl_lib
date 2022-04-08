;  Name : fiss_wv_image2
;
;  Purpose : make images and spectrograph for each x-frame
;
;  Calling Sequence : fiss_wv_image2, f_list
;
;  Input
;
;   - f_list : FISS filelist to make images
;   
;   - image_wave : wavelength for image, defaule=center(0.0 A)
;   
;  Output : image files in the subdir(name = observed time + waveband)
;   
    
pro fiss_wv_image2, f_list, image_wave=image_wave

if n_elements(image_wave) eq 0 then image_wave=0.
for file=0, n_elements(f_list)-1 do begin
    f=f_list[file]
    data=readfits(f, h, /sil)
    wvpix=(image_wave/fxpar(h, 'CDELT1'))+fxpar(h, 'CRPIX1') 
    window, 0, xs=(size(data))[2]+(size(data))[1], ys=(size(data))[3]
    h_alpha=strmatch(sxpar(h, 'WAVELEN'), '6562*')
    if h_alpha eq 1 then loadct, 3, /sil else loadct, 8, /sil
    date=sxpar(h, 'DATE')
    subdir=strcompress(strmid(date, 11, 2)+'_'+strmid(date, 14, 2)+'_'+$
                       strmid(date, 17, 2)+'_'+sxpar(h, 'WAVELEN')+'_2', /remove_all)
    file_mkdir, subdir
    cd, subdir                   
    for i=0, (size(data))[2]-1 do begin
        tvscl, data[wvpix, *, *], 0
        plots, [i, i], [0, (size(data))[3]-1], color=255, /dev
        if fxpar(h, 'CDELT1') lt 0 then begin
           tvscl, rotate(reform(data[*, i, *]), 5), (size(data))[2], 0
        endif else begin
           tvscl, reform(data[*, i, *]), (size(data))[2], 0
        endelse              
        if image_wave ge 0 then begin
           xyouts, 0.05, 0.9, '+'+string(image_wave, format='(f3.1)')+!angstrom, $
                   /normal, charsize=2, color=255
        endif else begin
           xyouts, 0.05, 0.9, string(image_wave, format='(f4.1)')+!angstrom, $
                   /normal, charsize=2, color=255
        endelse         
        xyouts, 0.05, 0.05, string(fxpar(h, 'ENDTIME')), color=255, $
                charsize=2, /normal                                                         
;    stop
        write_png, strcompress(string(i)+'.png', /remove_all), tvrd(/true)
    endfor    
    cd, '..'
endfor
wdelete
loadct, 0, /sil
end