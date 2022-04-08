!p.color=255
!p.background=0
xc=500d
yc=-160d
fov=240./60.
drange1=[[4500, 1500, 12000], $
         [1700,  300, 12000], $
         [ 304,  50, 12000], $
         [1600,  100, 10000], $
         [ 171, 1000, 12000], $
         [ 193,  800, 15000], $
         [ 211,  400, 12000], $
         [ 335,   30, 12000], $
         [  94,   10, 12000], $
         [ 131,   50, 12000]]
wv1=[4500, 1700, 1600, 171, 193, 211, 335, 94, 131]
path='/data/home/chokh/sdo_130817'
wv1=304
    
for j=0, n_elements(wv1)-1 do begin
;    j=9
    wv=wv1[j]
    drange=drange1[1:2, where(drange1[0, *] eq wv)]
    out_dir=path+strcompress('/'+string(wv)+'/png2', /remove_all)
    cd, path+strcompress('/'+string(wv), /remove_all)
    file_mkdir, out_dir
    f=file_search('*.fits')
    sdo2map, f[fix(n_elements(f)/2.)], i_map, i_index
    
    for i=0, n_elements(f)-1 do begin
    ;for i=180, 185 do begin
;        i=70
        print, string(100.*i/(n_elements(f)), format='(f5.1)')+'%'
        cd, path+strcompress('/'+string(wv), /remove_all)
    ;    sdo2map, f[where(strmatch(f, '*18_05_07*') eq 1)], map, index
        sdo2map, f[i], map, index
        map.data=map.data/index.exptime*i_index.exptime
        if min(map.data) le -50 then map.data[where(map.data le -50)]=15000
        a_time=sdo_jultime(f[i])
        pos=rot_xy(xc, yc, tstart=i_index.date_obs, tend=index.date_obs)
        aia_lct, rr, gg, bb, wavelnth=index.wavelnth, /load
        window, 0, xs=800, ys=800
        plot_map, map, center=pos, fov=fov, charsize=1.5, $
                  drange=drange, /log_scale 
;        stop
        cd, out_dir
        caldat, a_time, mo, da, yr, hr, mi, se
        write_png, strcompress(string(hr, format='(i2.2)')+'_'+$
                               string(mi, format='(i2.2)')+'_'+$
                               string(se, format='(i2.2)')+'.png', /remove_all), $
                   tvrd(true=1)
        cd, path
    endfor
    
    ;write README file
    cd, out_dir
    openw, 1, 'readme.txt'
    printf, 1, 'sdo_hmi_aia2.pro'
    printf, 1, 'xcen ='+string(xc)
    printf, 1, 'ycen ='+string(yc)
    printf, 1, 'FOV ='+string(fov)
    printf, 1, 'wavelength ='+string(wv)
    printf, 1, 'data min ='+string(drange[0]) 
    printf, 1, 'data max ='+string(drange[1])
    close, 1
endfor    
 
print, 'Finished!'
end
