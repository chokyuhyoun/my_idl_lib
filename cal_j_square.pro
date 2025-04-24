function cal_j_square, bx, by, bz
;file = '/sanhome/khcho/IRIS2_bfield/20220208_013409_3620108076/field.dat'
;Read_bfield_fff, file, xsize, ysize, zsize, bx, by, bz, x, y, z  ; lon, lat, r

if total(size(bx) ne size(by)) or total(size(by) ne size(bz)) then begin
  print, 'sizes of Bx, By and Bz do not match."
  return, -1 
endif

sz = size(bx)
xp = findgen(sz[1])
yp = findgen(sz[2])
zp = findgen(sz[3])

xpm = findgen(sz[1]-1) + 0.5
ypm = findgen(sz[2]-1) + 0.5
zpm = findgen(sz[3]-1) + 0.5

bz_ = interpolate(bz, xp[1:-2], ypm, zp[1:-2], /grid)
by_ = interpolate(by, xp[1:-2], yp[1:-2], zpm, /grid)
jx = (bz_[*, 1:*, *] - bz_[*, 0:-2, *]) - (by_[*, *, 1:*] - by_[*, *, 0:-2])
delvar, bz_, by_

bx_ = interpolate(bx, xp[1:-2], yp[1:-2], zpm, /grid)
bz_ = interpolate(bz, xpm, yp[1:-2], zp[1:-2], /grid)
jy = (bx_[*, *, 1:*] - bx_[*, *, 0:-2]) - (bz_[1:*, *, *] - bz_[0:-2, *, *])
delvar, bx_, bz_

by_ = interpolate(by, xpm, yp[1:-2], zp[1:-2], /grid)
bx_ = interpolate(bx, xp[1:-2], ypm, zp[1:-2], /grid)
jz = (by_[1:*, *, *] - by_[0:-2, *, *]) - (bx_[*, 1:*, *] - bx_[*, 0:-2, *])
delvar, by_, bx_

j_sq = jx^2. + jy^2. + jz^2.
return, j_sq
; Note that the j_sq has the 2 pixels smaller size (cropping first and last pixels) 
; for all dimension. 

end

function lonlat2helcen, r, lonpp, latpp, r_sun
  if n_elements(r) eq 1 then begin
    sphere_co = transpose([[lonpp[*]], [latpp[*]], [replicate(r_sun, n_elements(lonpp))]])
    helcen_co = cv_coord(from_sphere=sphere_co, /to_rect) ; in arcsec
    helcen_co = reform(helcen_co, 3, (size(lonpp))[1], (size(lonpp))[2]) 
    return, [[[reform(helcen_co[1, *, *])]], [[reform(helcen_co[2, *, *])]]]
  endif else begin
    lon = interpolate(lonpp, r[*, 0], r[*, 1])
    lat = interpolate(latpp, r[*, 0], r[*, 1])
    h = r[*, 2]*0.5 + r_sun  ; in arcsec
    sphere_co = transpose([[lon[*]], [lat[*]], [h[*]]])
    helcen_co = cv_coord(from_sphere=sphere_co, /to_rect) ; in arcsec
  endelse
  return, shift(transpose(helcen_co), 0, -1)
end


pro aia_syn_img, i_, thres_b=thres_b
;i_ = 7
if n_elements(thres_b) eq 0 then thres_b = 100.

path = '/sanhome/khcho/IRIS2_bfield/'
cd, path
restore, path+'/target_info.sav'
save_path = path + file_basename(target_info[i_].data_path)
restore, save_path+'/nlfff_input.sav'

save_path2 = path+'syn_aia_results/'
file_mkdir, save_path2
Read_bfield_fff, save_path+'/field.dat', xsize, ysize, zsize, bx, by, bz, x, y, z  ; lon, lat, r

j_sq = cal_j_square(bx, by, bz)
bx_ = bx[1:-2, 1:-2, 1:-2]
by_ = by[1:-2, 1:-2, 1:-2]
bz_ = bz[1:-2, 1:-2, 1:-2]
lonpp_ = lonpp[1:-2, 1:-2]
latpp_ = latpp[1:-2, 1:-2]

b_pho = sqrt(bx_[*, *, 0]^2. + by_[*, *, 0]^2. + bz_[*, *, 0]^2.)

b_init0 = where(b_pho ge thres_b, /null)
b_init_pos = array_indices(b_pho, b_init0)
lines = list(!null)
lengths = []
total_j_sq = []

for i=0, (size(b_init_pos))[2]-1 do begin
  ds = (bz[b_init_pos[0, i], b_init_pos[1, i]] ge 0) ? 1 : -1
  b_line, bx_, by_, bz_, [b_init_pos[0, i], b_init_pos[1, i], 0], $
          r, ds=ds, length=length
  lines.add, r
  lengths = [lengths, length] 
  j_sq0 = interpolate(j_sq, r[*, 0], r[*, 1], r[*, 2])
  total_j_sq = [total_j_sq, total(j_sq0)]
endfor
lines.remove, 0

ref_time = anytim(target_info[i_].iris_time)
ssw_jsoc_time2data, anytim(ref_time, /ccsds), anytim(ref_time+6, /ccsds), $
  aia_index, ds='aia.lev1_euv_12s', wave=171, $
  /files_only, aia171_file, /silent
read_sdo, aia171_file[0], dum, aia171_data
get_xp_yp, aia_index, aia_xp, aia_yp

ssw_jsoc_time2data, anytim(ref_time, /ccsds), anytim(ref_time+45, /ccsds), $
  b_los_index, ds='hmi.M_45s', $
  /files_only, b_los_file, /silent, count=c1
read_sdo, b_los_file[0], dum, b_los_data
get_xp_yp, b_los_index, hmi_xp, hmi_yp, data=b_los_data


syn_aia = aia171_data*0.
for i=0, n_elements(lines)-1 do begin
;  i = 0
  if n_elements(lines[i]) le 3 then continue
  line_hc = lonlat2helcen(lines[i], lonpp_, latpp_, r_sun) ; in arcsec
  line_xpix = interpol(findgen(4096), aia_xp, line_hc[*, 0])
  line_ypix = interpol(findgen(4096), aia_yp, line_hc[*, 1])
  line_zpix = interpol(findgen(4096), aia_xp, line_hc[*, 2])
  line_dist_pix = sqrt((line_xpix[1:*]-line_xpix[0:-2])^2. + $
                       (line_ypix[1:*]-line_ypix[0:-2])^2. + $
                       (line_zpix[1:*]-line_zpix[0:-2])^2.)
  line_dist_pix_cum = total(line_dist_pix, /cum)
  line_dist_eq_ind = interpol(findgen(n_elements(line_xpix)), $
                              [0, line_dist_pix_cum], findgen(line_dist_pix_cum[-1]+1))
  line_eq_xpix = interpol(line_xpix, findgen(n_elements(line_xpix)), $
                          line_dist_eq_ind)
  line_eq_ypix = interpol(line_ypix, findgen(n_elements(line_ypix)), $
                          line_dist_eq_ind)

  line_eq_xpix0 = floor(line_eq_xpix)
  line_eq_ypix0 = floor(line_eq_ypix)
  delx = line_eq_xpix - line_eq_xpix0
  dely = line_eq_ypix - line_eq_ypix0
  bl_cont = (1.-delx)*(1.-dely)
  br_cont = delx*(1.-dely)
  ul_cont = (1.-delx)*dely
  
  ur_cont = delx*dely
  mean_j_sq = total_j_sq[i]/line_dist_pix_cum[-1]
  b_pho_stren = b_pho[b_init0[i]]
  b_pho_stren = 1.
  for j=0, n_elements(line_eq_xpix0)-1 do begin
    syn_aia[line_eq_xpix0[j], line_eq_ypix0[j]] += mean_j_sq*bl_cont[j]*b_pho_stren
    syn_aia[line_eq_xpix0[j]+1, line_eq_ypix0[j]] += mean_j_sq*br_cont[j]*b_pho_stren
    syn_aia[line_eq_xpix0[j], line_eq_ypix0[j]+1] += mean_j_sq*ul_cont[j]*b_pho_stren
    syn_aia[line_eq_xpix0[j]+1, line_eq_ypix0[j]+1] += mean_j_sq*ur_cont[j]*b_pho_stren
  endfor
endfor

aia_lct, rr, gg, bb, wave=171
aia171_ct = [[rr], [gg], [bb]]
iris_cen = target_info[i_].iris_cen
iris_fov = target_info[i_].iris_fov
xr = iris_cen[0]+150.*[-1, 1]
yr = iris_cen[1]+150.*[-1, 1]


w01 = window(dim=[8d2 ,8d2])
t00 = text(0.5, 0.93, file_basename(target_info[i_].data_path), $
           align=0.5, font_size=13, font_style=1)

im01 = image_(aia171_data, aia_xp, aia_yp, /current, /no_cb, $
              pos=[0.1, 0.5, 0.5, 0.9], rgb_table=aia171_ct, $
              min=0, max=1e3, xr=xr, yr=yr, xminor=5, yminor=5, $
              xshowtext=0)
c01 = contour(b_los_data, hmi_xp, hmi_yp, over=im01, $
              c_value=100*[-1, 1], c_color=['b', 'r'], transp=50)
t011 = text(mean(im01.pos[[0, 2]]), im01.pos[3]-0.02, 'AIA 171$\AA$ '+aia_index.date_obs, color='black', $
            font_style=1, align=0.5, vertical_align=1, font_size=11)              
t012 = text(t011.pos[0]-0.002, im01.pos[3]-0.018, t011.string, color='white', $
            font_style=1, align=0, vertical_align=1, font_size=11)
p011 = plot(iris_cen[0]+0.5*iris_fov[0]*[-1, -1, 1, 1, -1], $
            iris_cen[1]+0.5*iris_fov[1]*[-1, 1, 1, -1, -1], $
            'r2', transp=50, over=im01) 

border = lonlat2helcen(0, lonpp, latpp, r_sun)
ext = {color:'cyan', transp:50, thick:2, over:im01}
p0121 = plot(border[*, 0, 0], border[*, 0, 1], _extra=ext)
p0122 = plot(border[*, -1, 0], border[*, -1, 1], _extra=ext)
p0123 = plot(border[0, *, 0], border[0, *, 1], _extra=ext)
p0124 = plot(border[-1, *, 0], border[-1, *, 1], _extra=ext) 

;--------------------------------

im02 = image_(b_los_data, hmi_xp, hmi_yp, /current, /no_cb, $
  pos=[0.5, 0.5, 0.9, 0.9], rgb_table=0, $
  min=-5e2, max=5e2, xr=xr, yr=yr, xminor=5, yminor=5, $
  yshowtext=0)
c02 = contour(b_los_data, hmi_xp, hmi_yp, over=im02, $
    c_value=100*[-1, 1], c_color=['b', 'r'], transp=50)

t021 = text(mean(im02.pos[[0, 2]]), im02.pos[3]-0.02, 'HMI B$_{los}$ '+b_los_index.date_obs, color='black', $
  font_style=1, align=0.5, vertical_align=1, font_size=11)
t022 = text(t021.pos[0]-0.002, im02.pos[3]-0.018, t021.string, color='white', $
  font_style=1, align=0, vertical_align=1, font_size=11)
p021 = plot(iris_cen[0]+0.5*iris_fov[0]*[-1, -1, 1, 1, -1], $
  iris_cen[1]+0.5*iris_fov[1]*[-1, 1, 1, -1, -1], $
  'r2', transp=50, over=im02)


ext = {color:'cyan', transp:50, thick:2, over:im02}
p0221 = plot(border[*, 0, 0], border[*, 0, 1], _extra=ext)
p0222 = plot(border[*, -1, 0], border[*, -1, 1], _extra=ext)
p0223 = plot(border[0, *, 0], border[0, *, 1], _extra=ext)
p0224 = plot(border[-1, *, 0], border[-1, *, 1], _extra=ext)

;--------------------------------
dum = syn_aia[where(syn_aia gt 0)]
pdf = histogram(dum, loc=xbin)
cdf = total(pdf, /cum) / n_elements(dum)
lev = xbin[value_locate(cdf, 0.99)] 
 
im03 = image_(syn_aia, aia_xp, aia_yp, /current, /no_cb, $
  pos=[0.1, 0.1, 0.5, 0.5], rgb_table=aia171_ct, $
  max=lev, $
  xr=xr, yr=yr, xminor=5, yminor=5, $
  xtitle='Solar X (arcsec)', ytitle='Solar Y (arcsec)')
c03 = contour(b_los_data, hmi_xp, hmi_yp, over=im03, $
    c_value=100*[-1, 1], c_color=['b', 'r'], transp=50)


t031 = text(mean(im03.pos[[0, 2]]), im03.pos[3]-0.02, $
  'Synthetic AIA image', color='black', $
  font_style=1, align=0.5, vertical_align=1, font_size=11)
t032 = text(t031.pos[0]-0.002, im03.pos[3]-0.018, t031.string, color='white', $
  font_style=1, align=0, vertical_align=1, font_size=11)
p031 = plot(iris_cen[0]+0.5*iris_fov[0]*[-1, -1, 1, 1, -1], $
  iris_cen[1]+0.5*iris_fov[1]*[-1, 1, 1, -1, -1], $
  'r2', transp=50, over=im03)

ext = {color:'cyan', transp:50, thick:2, over:im03}
p0321 = plot(border[*, 0, 0], border[*, 0, 1], _extra=ext)
p0322 = plot(border[*, -1, 0], border[*, -1, 1], _extra=ext)
p0323 = plot(border[0, *, 0], border[0, *, 1], _extra=ext)
p0324 = plot(border[-1, *, 0], border[-1, *, 1], _extra=ext)

font_ext1 = {font_size:13, font_style:0}
t041 = text(0.52, 0.4, 'IRIS FoV', color=p011.color, transp=p011.transp, $
            _extra=font_ext1)
t042 = text(0.65, 0.4, 'NLFFF calculation FoV', color=p0121.color, transp=p0121.transp, $
            _extra=font_ext1)
t043 = text(0.52, 0.37, 'Starting point threshold |$\bfB\rm$| = '+string(thres_b, f='(i0)')+' G', $
            _extra=font_ext1)  
t044 = text(0.52, 0.34, '# of field lines for synthetic image: '+string(n_elements(lines), f='(i0)'), $
            _extra=font_ext1)

w01.save, save_path2+file_basename(target_info[i_].data_path)+'.png', resol=200, /bitmap
w01.close
;stop                          

end