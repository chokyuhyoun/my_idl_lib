pro observe, x_pos, y_pos, fov=fov, del=del

if ~keyword_set(fov) then fov=3.

path='/Users/khcho/Desktop/observe/'
file_mkdir, path
cd, path
time=systime(/jul, /utc)

if keyword_set(del) then begin
    f=file_search('*.jpg', count=n)
    if n ne 0 then file_delete, f
    ourl=obj_new('idlneturl')
    ourl->setproperty, url_scheme='http'
    ourl->setproperty, url_path='assets/img/latest/latest_4096_HMII.jpg'
    ourl->setproperty, url_host='sdo.gsfc.nasa.gov'
    fn=ourl->get(filename=string(time, f='(d13.5)')+'_HMII.jpg')
    ourl->setproperty, url_path='assets/img/latest/latest_4096_HMIB.jpg'
    fn=ourl->get(filename=string(time, f='(d13.5)')+'_HMIB.jpg')
    
    url2=obj_new('idlneturl')
    url2->setproperty, url_scheme='http'
    url2->setproperty, url_path='Research/Halpha/current/current2Kx2K.jpg'
    url2->setproperty, url_host='bbso.njit.edu/'
    fn=url2->get(filename=string(time, f='(d13.5)')+'_H_alpha.jpg')
endif

int_img_file=(file_search('*HMII.jpg'))[-1]
mag_img_file=(file_search('*HMIB.jpg'))[-1]
h_img_file=(file_search('*H_alpha.jpg'))[-1]
read_jpeg, int_img_file, int_img
read_jpeg, mag_img_file, mag_img
read_jpeg, h_img_file, h_img

;; find center : intensity
sz=4096
x_int=int_img[*, sz/2.]
x_int=x_int/mean(x_int[(sz/2.-1d3):(sz/2.+1d3)])
left_x_int=x_int[0:sz/2.]
right_x_int=x_int[sz/2.+1:*]
n_point=3
left_x_pix=fltarr(n_point)
right_x_pix=fltarr(n_point)
for i=0, n_point-1 do begin
    int_cri=i*0.1+0.1
    left_x_pix[i]=arr_eq(left_x_int, int_cri)
    right_x_pix[i]=arr_eq(right_x_int, int_cri)+sz/2.
endfor
x_cen=mean(0.5*(left_x_pix+right_x_pix))
cen_x_pos=((sz-1)*0.5-x_cen)*0.5043


y_int=int_img[sz/2., *]
y_int=y_int/mean(y_int[(sz/2.-1d3):(sz/2.+1d3)])
down_y_int=y_int[0:sz/2.]
up_y_int=y_int[sz/2.+1:*]
n_point=3
down_y_pix=fltarr(n_point)
up_y_pix=fltarr(n_point)
for i=0, n_point-1 do begin
    int_cri=i*0.1+0.1
    down_y_pix[i]=arr_eq(down_y_int, int_cri)
    up_y_pix[i]=arr_eq(up_y_int, int_cri)+sz/2.
endfor
y_cen=mean(0.5*(down_y_pix+up_y_pix))
cen_y_pos=((sz-1)*0.5-y_cen)*0.5043

int_map=make_map(int_img, dx=0.5043, dy=0.5043, xc=cen_x_pos, yc=cen_y_pos)
get_xp_yp, int_map, int_xp, int_yp


;; find center : magnetogram
x_cen=((where(mag_img[0:sz/2., sz/2.] eq 0))[-1]+ $
       (where(mag_img[sz/2.:*, sz/2.] eq 0))[0]+sz/2.)*0.5
y_cen=((where(mag_img[sz/2., 0:sz/2.] eq 0))[-1]+ $
       (where(mag_img[sz/2., sz/2.:*] eq 0))[0]+sz/2.)*0.5
cen_x_pos=((sz-1)*0.5-x_cen)*0.5043       
cen_y_pos=((sz-1)*0.5-y_cen)*0.5043
mag_map=make_map(mag_img, dx=0.5043, dy=0.5043, xc=cen_x_pos, yc=cen_y_pos)
get_xp_yp, mag_map, mag_xp, mag_yp

;; find center : H alpha 
sz=(size(h_img))[1]
x_int=h_img[*, sz/2.]
x_int=x_int/mean(x_int[(sz/2.-1d3):(sz/2.+1d3)])
left_x_int=x_int[0:sz/2.]
right_x_int=x_int[sz/2.+1:*]
n_point=3
left_x_pix=fltarr(n_point)
right_x_pix=fltarr(n_point)
for i=0, n_point-1 do begin
    int_cri=i*0.1+0.1
    left_x_pix[i]=arr_eq(left_x_int, int_cri)
    right_x_pix[i]=arr_eq(right_x_int, int_cri)+sz/2.
endfor
x_cen=mean(0.5*(left_x_pix+right_x_pix))
cen_x_pos=((sz-1)*0.5-x_cen)*1.0015


y_int=h_img[sz/2., *]
y_int=y_int/mean(y_int[(sz/2.-1d3):(sz/2.+1d3)])
down_y_int=y_int[0:sz/2.]
up_y_int=y_int[sz/2.+1:*]
n_point=3
down_y_pix=fltarr(n_point)
up_y_pix=fltarr(n_point)
for i=0, n_point-1 do begin
    int_cri=i*0.1+0.1
    down_y_pix[i]=arr_eq(down_y_int, int_cri)
    up_y_pix[i]=arr_eq(up_y_int, int_cri)+sz/2.
endfor
y_cen=mean(0.5*(down_y_pix+up_y_pix))
cen_y_pos=((sz-1)*0.5-y_cen)*1.0015

h_map=make_map(h_img, dx=1.0015, dy=1.0015, xc=cen_x_pos, yc=cen_y_pos)
get_xp_yp, h_map, h_xp, h_yp

w01 = window(dim=[8d2, 8d2])
im01 = image_(int_map.data, int_xp, int_yp, /current)
im02 = image_(mag_map.data, mag_xp, mag_yp, over=im01)
im03 = image_(h_map.data, h_xp, h_yp)

ng_blink, [im01, im02, im03]

;win_s=8d2
;window, 0, xs=win_s, ys=win_s
;plot_map_d, int_map, center=[x_pos, y_pos], fov=fov
;
;window, 1, xs=win_s, ys=win_s
;plot_map_d, mag_map, center=[x_pos, y_pos], fov=fov
;
;window, 2, xs=win_s, ys=win_s
;n_pos=rot_xy(x_pos, y_pos, 3d1*6d1)
;plot_map_d, h_map, center=n_pos, fov=fov


;stop
blink, [0, 1, 2], 1

end

observe, 60, 342, fov=5, del=1


end 