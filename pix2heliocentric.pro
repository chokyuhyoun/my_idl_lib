pro pix2heliocentric, px, py, h, lon, lat, carrington=carrington 
    r_sun=fxpar(h, 'rsun_obs')
    xc=fxpar(h, 'crpix1')
    yc=fxpar(h, 'crpix2')
    dx=fxpar(h, 'cdelt1')
    dy=fxpar(h, 'cdelt2')
    lat=asin((py-yc)*dy/r_sun)
    lon=asin((px-xc)*dy/(r_sun*cos(lat*!dtor)))
    lat=lat*!radeg
    lon=lon*!radeg
    if keyword_set(carrington) then begin
        lat=lat+fxpar(h, 'crlt_obs')
        lon=lon+fxpar(h, 'crln_obs')
    endif
end


cd, 'C:\Users\chokh\Desktop\eklim'
aia_file=file_search('aia.lev1.304A_2015-06-21T02_23_07.13Z.image_lev1.fits')
hmi_file=file_search('hmi.m_45s.2015.06.21_02_24_00_TAI.magnetogram.fits')
aia_data=readfits(aia_file[0], h1)
hmi_data=readfits(hmi_file[0], h2)
hmi_data=rotate(hmi_data, 2)

xr=[-800, 800]
yr=[-800, 800]
binning=3

lcent=290.14
bcent=-36.14
xsize=700
ysize=700
width=0.3

data2pix, xr, yr, h1, dx, dy
x=dx[0]+findgen((dx[1]-dx[0])/binning)*binning
y=dy[0]+findgen((dy[1]-dy[0])/binning)*binning
pix2heliocentric, x, y, h1, lon, lat, /carrington
aia_part=interpolate(aia_data, x, y, /grid)
aia_part=bytscl(alog10((aia_part*(4.99941/fxpar(h1, 'exptime'))>15<600)))
aia304_data=spherical_image_create(aia_part,lon,lat,1)

data2pix, xr, yr, h2, dx, dy
x=dx[0]+findgen((dx[1]-dx[0])/binning)*binning
y=dy[0]+findgen((dy[1]-dy[0])/binning)*binning
pix2heliocentric, x, y, h2, lon, lat, /carrington
hmi_part=interpolate(hmi_data, x, y, /grid)
hmi_part=bytscl(hmi_part, min=-1d3, max=1d3)
hmi_data=spherical_image_create(hmi_part,lon,lat,1)

restore, 'C:\Users\chokh\Desktop\eklim\pfss\pfss.sav'

spherical_trackball_widget, pfss_data, im_data=hmi_data, imsc=[0, 255]
stop
;pfss_draw_field,outim=outim,bcent=bcent,lcent=lcent,width=width, open=open
;
;set_plot, 'ps'
;device, filename='hmi_pfss.eps', $
;        /encapsulated, xs=10, ys=10, bits_per_pixel=8, /color, /isolatin1
;map_set, bcent, lcent, /orthographic, /isotropic
;wrap=map_image(hmi_part, lonmin=min(lon), lonmax=max(lon), $
;                         latmin=min(lat), latmax=max(lat), /bilinear)
;color=(open eq 1) : 150 ? 255
;tv, wrap
;for i=0, 
;xp=ptr(0:ns-1,*)*sin(ptth(0:ns-1,i))*sin(ptph(0:ns-1,i)-lcent(0)*!dtor)
;yp=ptr(0:ns-1,*)*sin(ptth(0:ns-1,i))*cos(ptph(0:ns-1,i)-lcent(0)*!dtor)
;zp=ptr(0:ns-1,*)*cos(ptth(0:ns-1,i))
;
;;  now latitudinal tilt
;xpp=xp
;ypp=cb*yp-sb*zp
;zpp=sb*yp+cb*zp
;
;
;plots,  
;xyouts, 0.05, 0.05, $
;        fxpar(h2, 'telescop')+' '+fxpar(h2, 'content')+' '+fxpar(h2, 'date-obs'), $
;        /normal, charsize=3, charthick=3, color=255
;        
;device, /close
;set_plot, 'win'
;window,0,xsiz=nax(0),ysiz=nax(1)
;tv,outim
         




end