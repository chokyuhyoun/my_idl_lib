function nave_track, im1, im2, fwhm,  pos1, dx, dy,  sigma=sigma, noise=noise, itmax=itmax
;
;+
; NAME: NAVE_TRACK
;
; PURPOSE:
;         Determine the position of a Lagrangian trajectory at t2
;         that was at a specified position at t1
;
; CALLING SEQUENCE:
;          pos2=Nave_track(im1, im2, fwhm, pos1, sigma=sigma)
; INPUTS:
;         im1     Image at t1
;         im2     Image at t2
;         fwhm    fwhm of the window to be used in NAVE
;         pos1    Position(s) at t1
;                      pos1[0,*] =x
;                      pos1[1,*] =y
; OUTPUTS:
;         pos2    Positon(s) at t2
; Keyword Output
;         cor     correlation
; REQUIRED ROUTINES:
;         NAVE_POINT
; HISTORY:
;          2008 April: J. Chae first coded.
;          2008 November
;          2008 December
;-

if n_elements(itmax) eq 0 then itmax=2
xf=float(pos1[0,*])
yf=float(pos1[1,*])
dx=0. & dy=0.
for k=1, itmax do begin
par=nave_point(im1, im2, xf+0.5*dx, yf+0.5*dy, fwhm, noise=noise, sigma=sigma)
dx=par[0,*]
dy=par[1,*]
endfor
pos2=double(pos1)
pos2[0,*] = xf+ dx
pos2[1,*]=  yf+ dy
return, pos2
end
