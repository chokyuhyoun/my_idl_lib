pro IRIS_MOSAIC_GET_HMI, start_time, end_time, ofolder, $
	gzip = gzip

;+
;
;
;
;
;
;-

a = VSO_SEARCH(start_time, end_time, instrument='hmi', physobs='los_magnetic_field',/url)
if (is_struct(a) eq 0) then goto, slop
sock_copy, a.url, err=err, out_dir = ofolder

ff = FILE_SEARCH(CONCAT_DIR(ofolder, 'hmi.m_45s.*_TAI.magnetogram.fits'), count = fc)

tmp = str_sep(start_time,':')
start_time_fix = tmp[0]+'_'+tmp[1]+'_'+tmp[2]

hmi_file = CONCAT_DIR(ofolder, 'hmi.'+start_time_fix+'.map.sav')
help, hmi_file
if file_exist(hmi_file) or  file_exist(hmi_file+'.gz') then goto, slop

for jj=0,fc-1 do begin
    if jj eq 0 then begin
	fits2map, ff[jj], tmp, index = index
    endif else begin
	fits2map, ff[jj], mdi
	tmp.data = tmp.data + mdi.data
    endelse
endfor
tmp.data = fix(tmp.data/float(fc))
mdi = tmp

aa = size(mdi.data)
nx = aa[1]
ny = aa[2]

solarx = mdi.dx*(findgen(nx) - nx/2) + mdi.xc

solary = mdi.dy*(findgen(ny) - ny/2) + mdi.yc
r = mdi

r.data = 0.

for ii=0,nx-1 do for jj=0,ny-1 do r.data[ii,jj] = sqrt(solarx[ii]^2 + solary[jj]^2) / mdi.rsun

r.id = 'Solar Radius'
badpix = where(r.data ge 0.999, bpc)
if bpc gt 0 then mdi.data[badpix] = 0.

tmp = make_map(fix(mdi.data), xc = mdi.xc, yc = mdi.yc, dx = mdi.dx, dy = mdi.dy, id = mdi.id, dur = mdi.dur, $
	xunits = xunits, yunits = yunits, roll_angle = mdi.roll_angle, roll_center = mdi.roll_center, soho = 0, $
	l0 = mdi.l0, b0 = mdi.b0, rsun = mdi.rsun, time = mdi.time)
hmi = tmp
plot_map, hmi, dmin = -100, dmax = 100
save, file = hmi_file, hmi, index, fc

; clean_up
for jj=0,fc-1 do spawn, 'rm -f '+ff[jj]

if keyword_set(gzip) then spawn, 'gzip -f '+hmi_file

slop:

end
