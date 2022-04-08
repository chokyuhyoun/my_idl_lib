pro dup_cross, x_pos, y_pos, mag=mag, _extra=extra
    if ~keyword_set(mag) then mag=1.8
    if ~n_elements(extra) then extra={dum:0.}
    if ~total(strmatch(tag_names(extra), 'symsize', /fold_case)) then begin
        extra=create_struct(extra, 'symsize', 2.)
    endif
    if ~total(strmatch(tag_names(extra), 'thick', /fold_case)) then begin
        extra=create_struct(extra, 'thick', 2.)
    endif
    loadct, 0, /sil
    plots, x_pos, y_pos, psym=1, color=255, _extra=extra, /data
    extra.thick=extra.thick/mag
    extra.symsize=extra.symsize/mag
    plots, x_pos, y_pos, psym=1, color=0, _extra=extra, /data
end