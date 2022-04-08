function fiss_rot, data, angle 
    data_size=size(data)
    new_data=fltarr(data_size[1], data_size[2], data_size[3])
    for dum=0, data_size[1]-1 do begin
        new_data[dum, *, *]=rot(reform(data[dum, *, *]), angle, /interp)
;        new_data[dum, *, *]=rotate(reform(new_data[dum, *, *]), 5)
    endfor
    return, new_data
end

;  Find the FISS center of coordinate at particular time  
!p.background=0
!p.color=255

fiss_path='/data/fiss/2013/08/17/proc/ar'
sdo_path='/data/home/chokh/130817/sdo_130817/intensity'
out_path='/data/home/chokh/130817/fiss_130817'
align_result_path='/data/home/chokh/130817/fiss_130817/align_result'

file_mkdir, out_path
file_mkdir, align_result_path

cd, sdo_path
sdo_file=file_search('*.fits')
t_sdo=sdo_jultime(sdo_file)

cd, fiss_path
i_ha_file=file_search('*A1.fts')
i_ca_file=file_search('*B1.fts')

;stop
;; file division 
initial=251
final=310

;; Do you want to align between FISS files? ( 1 = ON / 0 = OFF ) 
align=1

pix=15      ;----- align box size
ca_levels=[10200, 11200]

ref_angle=9.6d0

ha_file=i_ha_file[initial:final]
ca_file=i_ca_file[initial:final]
;ha_file=[i_ha_file[initial],i_ha_file[final]]
;ca_file=[i_ca_file[initial],i_ca_file[final]]

if align then begin 
    i_ha_data=readfits(ha_file[fix(n_elements(ha_file)/2)], ha_h, /sil)
        
    i_ha_img=reform(i_ha_data[0, *, *])
    i_ha_size=size(i_ha_data)
        
    ;; embed the data into expanded array 
    space=fix(sqrt((i_ha_size[2]>i_ha_size[3])^2.+(i_ha_size[2]>i_ha_size[3])^2.))
    i_b_ha_data=fltarr(space, space)
    i_b_ha_data[ $
             fix(0.5*(space-i_ha_size[2])):fix(0.5*(space-i_ha_size[2]))+i_ha_size[2]-1, $
             fix(0.5*(space-i_ha_size[3])):fix(0.5*(space-i_ha_size[3]))+i_ha_size[3]-1] $
             =i_ha_img
    
    ;!!! FISS data is aligned with SDO data at 8.40 hour(about 8h 20m) = ref_angle
    ;         + y axis symmetry every day. 
    i_angle=(ref_angle+(fiss_jultime(ha_file[fix(n_elements(ha_file)/2.)]) mod 1d)*24d)*15d0
    i_rb_ha_data=rot(i_b_ha_data, i_angle, /interp)

    
    ;; make the reference image to align the data set
    window, 0, xs=space, ys=space
    loadct, 3, /sil
    tvscl, i_rb_ha_data
    loadct, 0, /sil
    xyouts, 0.05, 0.9, '!3Ref. image : '+ha_file[fix(n_elements(ha_file)/2.)], $
            color=255, charsize=1, /normal 
    print, 'Click the center of box(size:'+strcompress(string(pix*2+1))+$
             '*'+strcompress(string(pix*2+1))+') to align the data set'
    cursor, x1, y1, /dev
    plots, [x1-pix, x1+pix, x1+pix, x1-pix, x1-pix], $
           [y1+pix, y1+pix, y1-pix, y1-pix, y1+pix], color=255, /device
    plots, x1, y1, psym=1, thick=2, /dev       
    i_img=reform(i_rb_ha_data[x1-pix:x1+pix, y1-pix:y1+pix])   
;    wait, 0.1          
endif
;stop
auto=0

;for i=0, n_elements(ca_file)-1, n_elements(ca_file)-1 do begin
for i=0, n_elements(ca_file)-1 do begin
;    i=11

    print, 'file_no : '+string(initial+i, f='(i3)'), $
           strcompress(string(i*100./n_elements(ha_file), format='(f5.1)')+'%')
    print, ha_file[i]
;; read Ha & CaII data
    cd, fiss_path
    ha_data=readfits(ha_file[i], ha_h, /sil)
    ca_data=readfits(ca_file[i], ca_h,/ sil)
    ha_size=size(ha_data)
    ca_size=size(ca_data)
    space=fix(sqrt((ha_size[2]>ha_size[3])^2.+(ha_size[2]>ha_size[3])^2.))

;; align between Ha and Ca II
    ha_img=reform(ha_data[0, 0:ca_size[2]-1, *])
    ca_img=reform(ca_data[0, *, *])
    h_c_del=(round(alignoffset(ha_img, ca_img)))[0]
        
;; embed the data into expanded array 
    b_ha_data=fltarr(ha_size[1], space, space)
    emb_pos=[fix(0.5*(space-ha_size[2])), fix(0.5*(space-ha_size[3]))]
    b_ha_data[*, emb_pos[0]:emb_pos[0]+ha_size[2]-1, $
                 emb_pos[1]:emb_pos[1]+ha_size[3]-1] $
          =ha_data
    b_ca_data=fltarr(ca_size[1], space, space)
    b_ca_data[*, emb_pos[0]+h_c_del:emb_pos[0]+h_c_del+ca_size[2]-1, $
                 emb_pos[1]:emb_pos[1]+ca_size[3]-1] $
          =ca_data
;stop
    
;; rotation 
;; FISS data at 14.616 hour(about 14h 37m) in every day = SDO data. 
    angle=(ref_angle+(fiss_jultime(ha_file[i]) mod 1d)*24d)*15d0
    rb_ha_data=fiss_rot(b_ha_data, angle)
    rb_ca_data=fiss_rot(b_ca_data, angle)

;; align
    if (align eq 1) then begin
        window, 1, xs=space, ys=space
        loadct, 3, /sil
        tvscl, rb_ha_data[0, *, *]
        loadct, 0, /sil
        xyouts, 0.05, 0.9, 'Obj. image : '+ha_file[i], $
                color=255, charsize=1, /normal
;        print, 'Click the center of box(size:'+strcompress(string(pix*2+1))+$
;                 '*'+strcompress(string(pix*2+1))+') to align the data set'
;        cursor, x2, y2, /dev
        x2=x1
        y2=y1
        plots, [x2-pix, x2+pix, x2+pix, x2-pix, x2-pix], $
               [y2+pix, y2+pix, y2-pix, y2-pix, y2+pix], color=255, /device
        plots, x2, y2, psym=1, thick=2, /dev
;        wait, 0.1          
     
        h_img=reform(rb_ha_data[0, x2-pix:x2+pix, y2-pix:y2+pix])
        h_del=alignoffset(i_img, h_img)+[x1-x2, y1-y2]
        srb_ha_data=fltarr(ha_size[1], space, space)
        for dum=0, ha_size[1]-1 do $
            srb_ha_data[dum, *, *]=shift_sub(reform(rb_ha_data[dum, *, *]), h_del[0], h_del[1])

;        c_img=reform(rb_ca_data[0, x2-pix:x2+pix, y2-pix:y2+pix])
;        c_del=alignoffset(i_img, c_img)+[x1-x2, y1-y2]
        srb_ca_data=fltarr(ca_size[1], space, space)
        for dum=0, ca_size[1]-1 do $
            srb_ca_data[dum, *, *]=shift_sub(reform(rb_ca_data[dum, *, *]), h_del[0], h_del[1])
     endif else begin
        srb_ha_data=rb_ha_data
        srb_ca_data=rb_ca_data
     endelse   

;; find the center coord. of FISS data    
    cd, fiss_path
    if n_elements(fiss_pos) eq 0 then begin 
       fiss_pos=[fxpar(ca_h, 'TEL_XPOS'), fxpar(ca_h, 'TEL_YPOS')]
    endif else begin
       fiss_pos=rot_xy(fiss_pos[0], fiss_pos[1], $
                       (fiss_jultime(ca_file[i])-fiss_jultime(ca_file[i-1]))*86400d)
    endelse   
    fiss_pos[0]=fiss_pos[0] $
          -0.5d0/1080d0*(fiss_jultime(ca_file[i])-fiss_jultime(ca_file[i-1]))*86400d
    fiss2map, srb_ca_data, ca_h, fiss_ca_map, wv=-5, xc=fiss_pos[0], yc=fiss_pos[1]
    fiss_fov=space*0.16/6d1
;    fiss_half_time=fxpar(ca_h, 'ELAPTIME')*0.5    ; [sec]
    t_fiss=fiss_jultime(ca_file[i])-7d0/86400d   ; which part do you want to fit?
    n=where(abs(t_sdo-t_fiss) eq min(abs(t_sdo-t_fiss)))
    
    cd, sdo_path
    sdo2map, sdo_file[n], sdo_map, sdo_index


    window, 4, xs=700, ys=700
    
    plot_align :
    pos=rot_xy(fiss_pos[0], fiss_pos[1], $
               (sdo_jultime(sdo_file[n])-t_fiss)*86400d)
    plot_map_d, sdo_map, center=pos, fov=fiss_fov, /log_scale, $
              drange=[3d4, 7d4]
    loadct, 0, /sil
    plot_map_d, fiss_ca_map, center=fiss_pos, fov=fiss_fov, $
                levels=ca_levels, c_colors=[50, 50], c_thick=[3,1], $
                /cont, /noerase, /noaxes, /notitle      
    xyouts, 0.02, 0.05, i_ha_file[initial+i], color=255, charsize=2, /normal
    xyouts, 0.50, 0.05, string(initial+i), color=255, charsize=2, /normal
    xyouts, 0.55, 0.05, string(fiss_pos[0], fiss_pos[1]), color=255, charsize=2, /normal
;        stop
    if auto ne 1 then begin        
;; align confirmation
        repeat begin
          print, 'Used Fiss center position : xc = ' $
                  +string(fiss_pos[0], f='(f7.2)')+$
                  ', yc = '+string(fiss_pos[1], f='(f7.2)')
          print, 'Is it aligned? [ Y / N / STOP / AUTO / + / - ] 
          q=''
          read, q, prompt='[ Y / N / STOP / AUTO / + / -] : '
          q=strupcase(q)
        endrep until (q eq 'Y') or (q eq 'N') or (q eq 'STOP') or $
                     (q eq 'AUTO') or (q eq '+') or (q eq '-') or $
                     (q eq '++') or (q eq '--')
    
;; input new coord. of fiss center
        if strmatch(q, 'STOP') then begin
            stop
            goto, plot_align
        endif
        if strmatch(q, '+') then begin
            ca_levels=ca_levels+100. 
            goto, plot_align
        endif            
        if strmatch(q, '-') then begin
            ca_levels=ca_levels-100. 
            goto, plot_align
        endif
        if strmatch(q, '++') then begin
            ca_levels=ca_levels+500. 
            goto, plot_align
            
        endif
        if strmatch(q, '--') then begin
            ca_levels=ca_levels-500. 
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
        if q eq 'AUTO' then auto=1
     endif 

    cd, align_result_path
    wset, 4
    write_png, strcompress(string(initial+i), /remove_all), tvrd(true=1)


    
;; rewrite header
    check_fits, srb_ha_data, ha_h, /update, /sil
    fxaddpar, ha_h, 'TEL_XPOS', fiss_pos[0]
    fxaddpar, ha_h, 'TEL_YPOS', fiss_pos[1]
    fxaddpar, ha_h, 'ROTATION', angle, 'rotation angle (degree)
    check_fits, srb_ca_data, ca_h, /update, /sil    
    fxaddpar, ca_h, 'TEL_XPOS', fiss_pos[0]
    fxaddpar, ca_h, 'TEL_YPOS', fiss_pos[1]
    fxaddpar, ca_h, 'ROTATION', angle, 'rotation angle (degree)    
    
;; save data
    cd, out_path
    ha_dot_pos=strpos(ha_file[i], '.', /reverse_search)
    writefits, strcompress(strmid(ha_file[i], 0, ha_dot_pos)+'_rot_align.fts', $
                           /remove_all), srb_ha_data, ha_h
    ca_dot_pos=strpos(ha_file[i], '.', /reverse_search)
    writefits, strcompress(strmid(ca_file[i], 0, ca_dot_pos)+'_rot_align.fts', $
                           /remove_all), srb_ca_data, ca_h    
    
;stop    


endfor
auto=0    
wset, 0 & wdelete
;if align then wset, 1 & wdelete

end