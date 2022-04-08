;+
;
; NAME :
;          B_LFF
; PURPOSE :
;          Linear Force-Free Extrapolation of Magnetic Field
; CALLING SEQUENCE:
;          B_LFF, bz0, z, bx, by, bz, alpha=alpha, seehafer=seehafer
;
; INPUT :
;           bz0 : 2-d array of vertical field at z=0 plane
;           z   : 1-d array of heights (in unit of pixels)
; OUTPUT :
;           bx, by, bz : 3-d arrays of field components
; MODIFICATION HISTORY:
;        October 2002  Jongchul Chae, generalized from a_pot.pro
;                    Reference: Nakagawa and Raadu 1972, Solar Physics, 25, 127
;                                       Seehafer 1978, Solar Physics, 58, 215
;-
pro b_lff,  bz0, z, bx, by, bz, alpha=alpha1,seehafer=seehafer

if n_elements(alpha1) eq 0 then alpha1=0.


nx1=n_elements(bz0(*,0))
ny1=n_elements(bz0(0,*))
nz=n_elements(z)

if keyword_set(seehafer) then begin
nx=2*nx1  & ny=2*ny1
bz0e=fltarr(nx, ny)
bz0e(0:nx1-1, 0:ny1-1)=bz0
bz0e(nx1:nx-1, 0:ny1-1)= - rotate(bz0, 5)
bz0e(0:nx1-1, ny1:ny-1)= - rotate(bz0, 7)
bz0e(nx1:nx-1, ny1:ny-1)= -rotate(bz0e(0:nx1-1, ny1:ny-1), 5)
endif else begin
nx=nx1 & ny= ny1
bz0e=bz0
endelse


kx = 2*!pi*[findgen(nx/2+1),reverse(-1-findgen(nx-nx/2-1))]/nx
ky = 2*!pi*[findgen(ny/2+1),reverse(-1-findgen(ny-ny/2-1))]/ny

;if abs(alpha1) ge 1. then begin
;  print, 'the magnitude of alpha in B_LFF is too big! '
;  print, '|alpha| should be less than 1.'
;  return
;  end

alpha=alpha1*kx(1,0)  ; in unit of 2 pi / L_x
kx=kx#replicate(1, ny)
ky=replicate(1,nx)#ky
fbz0 = fft(bz0e, -1)
tmp = kx^2+ky^2 - alpha^2

;   We assume that the low frequency components are described by a potential field
s=tmp gt 0.
kz=sqrt(s*tmp)+ sqrt(kx^2+ky^2)*(1-s)   ; linear force free + potential

argx=fbz0*complex(0,-1)*(kx*kz-alpha*s*ky)/((kx^2+ ky^2)>kx(1,0)^2)
argy=fbz0*complex(0,-1)*(ky*kz+alpha*s*kx)/((kx^2+ ky^2)>ky(0,1)^2)
bx=fltarr(nx1,ny1,nz)
by=bx
bz=bx

for j=0, nz-1 do begin
tmp = (float(fft(argx*exp(-kz*z(j)),1)))

bx(*,*,j)=tmp[0:nx1-1, 0:ny1-1]
tmp = (float(fft(argy*exp(-kz*z(j)),1)))

by(*,*,j)=tmp[0:nx1-1, 0:ny1-1]
tmp = (float(fft(fbz0*exp(-kz*z(j)),1)))

bz(*,*,j)=tmp[0:nx1-1, 0:ny1-1]

endfor
end


