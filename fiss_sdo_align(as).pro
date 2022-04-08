;  Find the FISS center of coordinate at particular time  
!p.background=0
!p.color=255

fiss_path='/data/home/chokh/fiss_130817'
sdo_path='/data/home/chokh/sdo_130817/intensity'
out_path='/data/home/chokh/fiss_130817'
align_result_path='/data/home/chokh/fiss_130817/align_result'

file_mkdir, out_path
file_mkdir, align_result_path

cd, sdo_path
sdo_file=file_search('*.fits')
t_sdo=sdo_jultime(sdo_file)

cd, fiss_path
i_ha_file=file_search('*A1*.fts')
i_ca_file=file_search('*B1*.fts')

;stop
;; file select ************* 
i=624


ca_levels=[8000, 9500]


;; find the center coord. of FISS data    
    cd, fiss_path
    ca_data=readfits(i_ca_file[i], ca_h)
    ha_h=headfits(i_ha_file[i])
    fiss_pos=[fxpar(ca_h, 'TEL_XPOS'), fxpar(ca_h, 'TEL_YPOS')]
    fiss2map, ca_data, ca_h, fiss_ca_map, wv=-5, xc=fiss_pos[0], yc=fiss_pos[1]
    fiss_fov=(size(ca_data))[2]*0.16/6d1
;    fiss_half_time=fxpar(ca_h, 'ELAPTIME')*0.5    ; [sec]
    t_fiss=fiss_jultime(i_ca_file[i])-7d0/86400d   ; which part do you want to fit?
    n=where(abs(t_sdo-t_fiss) eq min(abs(t_sdo-t_fiss)))
    
    cd, sdo_path
    sdo2map, sdo_file[n], sdo_map, sdo_index

    window, 0, xs=700, ys=700
    
    plot_align : 
    pos=rot_xy(fiss_pos[0], fiss_pos[1], $
               (sdo_jultime(sdo_file[n])-t_fiss)*86400d)
    plot_map_d, sdo_map, center=pos, fov=fiss_fov, /log_scale, $
              drange=[3d4, 7d4]
    loadct, 0, /sil
    plot_map_d, fiss_ca_map, center=fiss_pos, fov=fiss_fov, $
                levels=ca_levels, c_colors=[50, 50], c_thick=[3,1], $
                /cont, /noerase, /noaxes, /notitle      
    xyouts, 0.02, 0.06, i_ha_file[i], color=255, charsize=2, /normal
    xyouts, 0.02, 0.02, string(i), color=255, charsize=2, /normal
    xyouts, 0.3, 0.02, string(fiss_pos[0], fiss_pos[1]), color=255, charsize=2, /normal
;        stop
        
;; align confirmation
    repeat begin
        print, 'Used Fiss center position : xc = ' $
                +string(fiss_pos[0], f='(f7.2)')+$
                ', yc = '+string(fiss_pos[1], f='(f7.2)')
        print, 'Is it aligned? [ Y / N / STOP / + / - ] 
        q=''
        read, q, prompt='[ Y / N / STOP / + / -] : '
        q=strupcase(q)
    endrep until (q eq 'Y') or (q eq 'N') or (q eq 'STOP') or $
                 (q eq '+') or (q eq '-') or (q eq '++') or (q eq '--')
    
;; input new coord. of fiss center
    if strmatch(q, 'STOP') then begin
        stop
        goto, plot_align
    endif
    if strmatch(q, '+') then begin
        ca_levels=ca_levels+300. 
        goto, plot_align
    endif
    if strmatch(q, '++') then begin
        ca_levels=ca_levels+300.*2 
        goto, plot_align
    endif
    if strmatch(q, '-') then begin
        ca_levels=ca_levels-300. 
        goto, plot_align
        
    endif
    if strmatch(q, '--') then begin
        ca_levels=ca_levels-300.*2 
        goto, plot_align
    endif
    if strmatch(q, 'N') then begin
       print, 'Please input new FISS center x coord.'
       fiss_pos_x=''
       read, fiss_pos_x, prompt='FISS center of x coord. : '
       if strmatch(fiss_pos_x, '') eq 1 then fiss_pos_x=fiss_pos[0]
       print, 'Please input new FISS center y coord.'
       fiss_pos_y=''
       read, fiss_pos_y, prompt='FISS center of y coord. : '
       if strmatch(fiss_pos_y, '') eq 1 then fiss_pos_y=fiss_pos[1]       
       fiss_pos=[float(fiss_pos_x), float(fiss_pos_y)]
       fiss_ca_map.xc=fiss_pos[0]
       fiss_ca_map.yc=fiss_pos[1]
       erase
       goto, plot_align
    endif

    cd, align_result_path
    write_png, strcompress(string(i), /remove_all), tvrd(true=1)
    wdelete, 0

    
;; rewrite header
;    check_fits, srb_ha_data, ha_h, /update, /sil
    fxaddpar, ha_h, 'TEL_XPOS', fiss_pos[0]
    fxaddpar, ha_h, 'TEL_YPOS', fiss_pos[1]

;    check_fits, srb_ca_data, ca_h, /update, /sil    
    fxaddpar, ca_h, 'TEL_XPOS', fiss_pos[0]
    fxaddpar, ca_h, 'TEL_YPOS', fiss_pos[1]
    
;; save data
    cd, out_path
;    ha_dot_pos=strpos(ha_file[i], '.', /reverse_search)
;    writefits, strcompress(strmid(ha_file[i], 0, ha_dot_pos)+'_rot_align.fts', $
;                           /remove_all), srb_ha_data, ha_h
;    ca_dot_pos=strpos(ha_file[i], '.', /reverse_search)
;    writefits, strcompress(strmid(ca_file[i], 0, ca_dot_pos)+'_rot_align.fts', $
;                           /remove_all), srb_ca_data, ca_h    
    modfits, i_ha_file[i], 0, ha_h
    modfits, i_ca_file[i], 0, ca_h
;stop    

end