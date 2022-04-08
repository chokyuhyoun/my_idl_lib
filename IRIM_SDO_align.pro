function spacing, data, space
    data_size=size(data)
    new_data=fltarr(space, space)
    new_data[fix(0.5*(space-data_size[1])): $
             fix(0.5*(space-data_size[1]))+data_size[1]-1, $
             fix(0.5*(space-data_size[2])): $
             fix(0.5*(space-data_size[2]))+data_size[2]-1] $
          =data
    return, new_data
end          


;  Find the IRIM center of coordinate at particular time  
!p.background=0
!p.color=255

irim_path='/data/NST/He10830'
sdo_path='/data/home/chokh/130817/sdo_130817/intensity'
out_path='/data/home/chokh/130817/He10830'
align_result_path='/data/home/chokh/130817/He10830/align_result'

file_mkdir, out_path
file_mkdir, align_result_path

cd, sdo_path
sdo_file=file_search('*.fits')
t_sdo=sdo_jultime(sdo_file)

cd, irim_path
irim_file=file_search('*.fts')
initial=828
final=850

;stop

ref_angle=20.60

auto=0

for i=initial, final do begin
;    i=11

    print, 'file_no : '+string(i, f='(i3)'), '        ', $
           strcompress(string((i-initial)*100./(final-initial), format='(f5.1)')+'%')
    print, irim_file[i]
;; read He10830 data
    cd, irim_path
    irim_data=readfits(irim_file[i], irim_h, /sil)
    irim_size=size(irim_data)
    space=fix(sqrt((irim_size[1]>irim_size[2])^2.+(irim_size[1]>irim_size[2])^2.))
        
;; embed the data into expanded array 
    b_irim_data=spacing(irim_data, space)
    
;; rotation 
;; IRIM data at 20.60 hour(about 20h 36m) in every day = SDO data. 
    angle=(ref_angle-(irim_jultime(irim_file[i]) mod 1d)*24d)*15d0
    rb_irim_data=rot(b_irim_data, angle, /interp)
    rb_irim_data=rotate(rb_irim_data, 5)
    srb_irim_data=rb_irim_data
   

;; find the center coord. of IRIM data    
    cd, irim_path
    if n_elements(irim_pos) ne 0 then begin 
        dum=irim_pos[1]
        irim_pos=rot_xy(irim_pos[0], irim_pos[1], $
                (irim_jultime(irim_file[i])-irim_jultime(irim_file[i-1]))*86400d)
        irim_pos=irim_pos-1./100.
    endif else begin
        irim_pos=[0, 0]
    endelse
    if fxpar(irim_h, 'TEL_XPOS') ne 0 then begin
        irim_pos=[fxpar(irim_h, 'TEL_XPOS'), fxpar(irim_h, 'TEL_YPOS')]
    endif        
    irim2map, srb_irim_data, irim_h, irim_map, xc=irim_pos[0], yc=irim_pos[1]
    irim_fov=space*0.079/6d1
    t_irim=irim_jultime(irim_file[i])   ; which part do you want to fit?
    n=where(abs(t_sdo-t_irim) eq min(abs(t_sdo-t_irim)))
    
    cd, sdo_path
    sdo2map, sdo_file[n], sdo_map, sdo_index

    window, 1, xs=900, ys=900
    
    plot_align : 
    pos=rot_xy(irim_pos[0], irim_pos[1], $
               (sdo_jultime(sdo_file[n])-t_irim)*86400d)
    loadct, 0, /sil
    plot_map_d, irim_map, center=irim_pos,  fov=irim_fov, /log_scale, $
                drange=[2d3, 7d3]
    loadct, 39, /sil
    plot_map_d, sdo_map, center=pos, fov=irim_fov, $
                levels=[27d3, 46d3], c_colors=[80, 254], c_thick=[2,2], $
                /cont, /noerase, /noaxes, /notitle      
    xyouts, 0.02, 0.08, sdo_file[n], color=255, charsize=2, /normal
    xyouts, 0.02, 0.05, irim_file[i], color=255, charsize=2, /normal
    xyouts, 0.50, 0.05, string(i), color=255, charsize=2, /normal
    xyouts, 0.55, 0.05, string(irim_pos[0], irim_pos[1]), color=255, $
                        charsize=2, /normal
;        stop
        
;; align confirmation
    if auto ne 1 then begin
        repeat begin
          print, 'Used IRIM center position : xc = ' $
                  +string(irim_pos[0], f='(f7.2)')+$
                  ', yc = '+string(irim_pos[1], f='(f7.2)')
          print, 'Is it aligned? [ Y / N / STOP / AUTO ] 
          q=''
          read, q, prompt='[ Y / N / STOP / AUTO ] : '
          q=strupcase(q)
        endrep until (q eq 'Y') or (q eq 'N') or (q eq 'STOP') or (q eq 'AUTO') 
    
;; input new coord. of IRIM center
        if strmatch(q, 'STOP') then begin
            stop
            goto, plot_align
        endif
        if strmatch(q, 'N') then begin
           print, 'Please input new IRIM center x coord.'
           irim_pos_x=''
           read, irim_pos_x, prompt='IRIM center of x coord. : '
           if strmatch(irim_pos_x, '') eq 1 then irim_pos_x=irim_pos[0]
           print, 'Please input new IRIM center y coord.'
           irim_pos_y=''
           read, irim_pos_y, prompt='IRIM center of y coord. : '
           if strmatch(irim_pos_y, '') eq 1 then irim_pos_y=irim_pos[1]       
           irim_pos=[float(irim_pos_x), float(irim_pos_y)]
           irim_map.xc=irim_pos[0]
           irim_map.yc=irim_pos[1]
           erase
           goto, plot_align
        endif
        if strmatch(q, 'AUTO') then auto=1
     endif 

    cd, align_result_path
    write_png, strcompress(string(i)+'.png', /remove_all), tvrd(true=1)
    wdelete,  1

    
;; rewrite header
    check_fits, srb_irim_data, irim_h, /update, /sil
    fxaddpar, irim_h, 'TEL_XPOS', irim_pos[0]
    fxaddpar, irim_h, 'TEL_YPOS', irim_pos[1]
    fxaddpar, irim_h, 'ROTATION', angle, 'rotation angle (degree)
    fxaddpar, irim_h, 'PIXSIZEX', 0.079, 'empirical value'
    fxaddpar, irim_h, 'PIXSIZEY', 0.079, 'empirical value'
    
;; save data
    cd, out_path
    irim_dot_pos=strpos(irim_file[i], '.', /reverse_search)
    writefits, strcompress(strmid(irim_file[i], 0, irim_dot_pos)+'_rot_align.fts', $
                           /remove_all), srb_irim_data, irim_h
 
    
;stop    


endfor
;wset, 1 & wdelete
;if align then wset, 1 & wdelete

end