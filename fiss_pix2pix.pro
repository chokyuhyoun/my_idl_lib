pro fiss_pix2pix, h1, x1, y1, h2, x2, y2
    on_error, 0
    dtor=!dpi/180d0
    if n_elements(x1) eq 0 or $
       n_elements(y1) eq 0 or $
       size(h2, /type) ne 7 then begin
       message, 'Incorrect argument. (!ºoº)!
    endif else begin
        x1=double(x1)
        y1=double(y1)
        if fxpar(h1, 'reverse') then rev=-1d0 else rev=1d0
        ang1=fxpar(h1, 'rotation')*rev*dtor
        ang2=fxpar(h2, 'rotation')*rev*dtor
        ew1=fxpar(h1, 'ew_off')
        ew2=fxpar(h2, 'ew_off')
        ns1=fxpar(h1, 'ns_off')
        ns2=fxpar(h2, 'ns_off')
        xx1=x1-(fxpar(h1, 'naxis2')-1.)*0.5
        yy1=y1-(fxpar(h1, 'naxis3')-1.)*0.5
        xx2=cos(-ang1)*xx1-sin(-ang1)*yy1+(ew2-ew1)
        yy2=sin(-ang1)*xx1+cos(-ang1)*yy1+(ns2-ns1)
        xx3=cos(ang2)*xx2-sin(ang2)*yy2
        yy3=sin(ang2)*xx2+cos(ang2)*yy2
        x2=xx3+(fxpar(h2, 'naxis2')-1.)*0.5
        y2=yy3+(fxpar(h2, 'naxis3')-1.)*0.5
        if total(x2 gt (fxpar(h2, 'naxis2')-1)) ne 0 or $
           total(x2 lt 0.) ne 0 or $
           total(y2 gt (fxpar(h2, 'naxis2')-1)) ne 0 or $
           total(y2 lt 0.) ne 0 then message, 'Result is outside of the data. (!ºoº)!' 
;        stop
    endelse  
end