function nave_point, fim0, sim0, x, y, fwhm, iter=itermax, chisq=chisq, $
            sigma=sigma, $
            gres=gres,  adv=adv,  $
            source=source, det=deta, $
            gv=gv, win=w, noise=noise, $
            np_deriv=np_deriv, cor=cor, par=par, background=background
;+
;   NAME: NAVE_POINT  =  Non-linear Affine Velocity Estimator
;                       at the  selected spatial points
;
;   PURPOSE:  Determine 6 parameters defining the affine velocity field
;             at the selected points
;
;   CALLING SEQUENCE:
;
;            Result = Nave_Point (fim, sim, x, y, fwhm)
;   INPUTS:
;            fim        Image at t1
;            sim        Image at t2;
;            x, y       arrays of x and y values of positions
;            fwhm       fwhms of the window function (can be arbitrary positive number )
;                          fwhmx, fwhmy
;
;
;
;   KEYWORD INPUTS:
;            adv        if set,  the advection equation is solved.
;            conti      if set, the continuity equation is solved.
;            noise      standard deviation of the noise in the difference between two
;                       images
;
;
;   OUTPUTS:
;            Result           parameters at  all the pixels of the images
;              Result(0,*) : x-component of velocity (U_0)
;              Result(1,*) : y-component of velocity (V_0)
;              Result(2,*) : x-derivative of x-component (U_x)
;              Result(3,*) : y-derivative of y-component (V_y)
;              Result(4,*) : y-derivative of x-component (U_y)
;              Result(5,*) : x-derivative of y-component (V_x)
;              Result(6,*) :  mu  (optional)
;              Result(7,*) :  cnst (optional)
;
;              It is assumed that the velocity field around (x_0, y_0) is of the form
;
;                              vx = U_0 + U_x * (x-x_0) + U_y * (y-y_0)
;                              vy = V_0 + V_x * (x-x_0) + V_y * (y-y_0)
;  KEYWORD OUTPUTS
;           Sigma         uncertainties in the parameters
;
;   REMARKS:
;
;        -.  The time unit is the time interval between two successive images,
;            and the length unit is the pixel size.
;
;
;   HISTORY
;
;              2007 Jana: J. Chae,  first coded.
;              2007 July:
;              2008 October:    Refined the definition of window and FWHM
;              2008 Decemeber:  positions are allowed to be off the grids
;                               (x- and y-values may be non-integers).
;              2009 February,  made more efficient
;-

fim=float(fim0)
sim=float(sim0)


if keyword_set(source) then qsw=1 else qsw=0
if n_elements(itermax) eq 0 then itermax=5
if n_elements(noise) ne 1. then noise=1.
if n_elements(np_deriv) eq 0 then np_deriv=3
if keyword_set(adv) then begin
psw=0
qsw=0
endif else psw=1
s=size(fim)
nx=s(1)
ny=s(2)


;  Constructing derivatives

if np_deriv eq 3 then kernel=[-1., 0, 1.]/2.   ; three-point differentiation
if np_deriv eq 5 then kernel =[0.12019d0, -0.74038d0, 0, 0.74038d0, -0.12019d0]   ; five-point differentiation
fim_x=convol(fim, kernel)
fim_y = convol(fim, transpose(kernel))
sim_x = convol(sim, kernel)
sim_y = convol(sim, transpose(kernel))

npoint=n_elements(x)


npar=6+qsw
if keyword_set(background) then npar=8
if n_elements(par) eq 0  then  $
par=fltarr(npar, npoint)  ; U_0, V_0, U_x, V_y, U_y, V_x and optionally mu

deta=fltarr(npoint)
gres=fltarr(npoint)
chisq=fltarr(npoint)
cor=fltarr(npoint)
sigma=fltarr(npar, npoint)
fwhmx = fwhm[0]
if n_elements(fwhm) eq 2 then fwhmy =fwhm[1] else fwhmy = fwhmx

 w=loc_win(fwhmx)
 w1=w/noise^2

nxs=n_elements(w[*,0])
nys=n_elements(w[0,*])
xs=(indgen(nxs)-nxs/2) # replicate(1, nys)
ys=replicate(1, nxs) # (indgen(nys)-nys/2)

A = fltarr(npar, npar)
B=fltarr(npar)
d=fltarr(nxs, nys, npar)


for ip=0L, npoint-1 do begin

x0=x[ip]
y0=y[ip]

for iter=0, itermax do begin

delxh = 0.5*( par[0,ip] + par[2,ip]*xs + par[4,ip]*ys )
delyh = 0.5*( par[1,ip] + par[5,ip]*xs + par[3,ip]*ys )


for sgn=-1, 1, 2 do begin
xx=x0+xs+sgn*delxh
yy=y0+ys+sgn*delyh
sx = fix(xx) & ex = xx-sx
sy = fix(yy) & ey = yy-sy
w00=(1.-ex)*(1.-ey)
w10=ex*(1.-ey)
w01=(1.-ex)*ey
w11=ex*ey
case sgn of
 -1:  begin
Fv = fim[sx, sy]*w00+ fim[sx+1, sy]*w10 $
  + fim[sx, sy+1]*w01+fim[sx+1,sy+1]*w11
Fxv = fim_x[sx, sy]*w00+ fim_x[sx+1, sy]*w10 $
  + fim_x[sx,sy+1]*w01+fim_x[sx+1,sy+1]*w11
Fyv = fim_y[sx, sy]*w00+ fim_y[sx+1, sy]*w10 $
  + fim_y[sx,sy+1]*w01+fim_y[sx+1,sy+1]*w11
end
 1:  begin
Sv = sim[sx, sy]*w00+ sim[sx+1,sy]*w10 $
  + sim[sx,sy+1]*w01+sim[sx+1,sy+1]*w11
 Sxv = sim_x[sx, sy]*w00+ sim_x[sx+1, sy]*w10 $
  + sim_x[sx,sy+1]*w01+sim_x[sx+1,sy+1]*w11
 Syv = sim_y[sx, sy]*w00+ sim_y[sx+1, sy]*w10 $
  + sim_y[sx,sy+1]*w01+sim_y[sx+1,sy+1]*w11
   end
endcase
endfor

nu = -(par[2,ip]+par[3,ip])*psw
if qsw then nu = nu-qsw*par[6,ip]

sdiv =exp(-nu/2.)
fdiv =1./sdiv
gv = Sv*sdiv- Fv*fdiv
if npar eq 8 then gv=gv+ par[7, ip]

if iter eq itermax then begin
deta[ip]=min(alog10(ww))
gres[ip]=gv[nxs/2, nys/2]
chisq[ip] =total(gv^2*w1)
sigma[*,ip]= sqrt(diag_matrix(invert(A)))
tmp=Sv*sdiv
cor[ip]=correlate(tmp, Fv*fdiv)
endif else begin

; Constructing coefficent arrays

tx =  (Sxv*sdiv +Fxv*fdiv)/2.
t0 = -(Sv *sdiv + Fv*fdiv)/2.
ty =  (Syv*sdiv +Fyv*fdiv)/2.
  d[*,*,0]= tx  ; U0
  d[*,*,1]= ty ; V0
  d[*,*,2]= tx*xs - psw*t0; Ux    ; ((xs*Sxv+k*Sv)*sdiv+(xs*Fxv+k*Fv)*fdiv)/2.
  d[*,*,3]= ty*ys - psw*t0 ; Vy   ;((ys*Syv+k*Sv)*sdiv+(ys*Fyv+k*Fv)*fdiv)/2.
  d[*,*,4]= tx*ys  ; Uy   ;(ys*Sxv*sdiv+ys*Fxv*fdiv)/2.
  d[*,*,5]= ty*xs  ; Vx  ;(xs*Syv*sdiv+xs*Fyv*fdiv)/2.
  if qsw then d[*,*,6]= -qsw*t0
  if npar eq 8 then d[*,*,7]= 1.
  for i=0, npar-1 do for j=0, i do begin
    A(j,i)= total(d[*,*,j]*d[*,*,i]*w1)
    A(i,j)=A(j,i)
  endfor

  for i=0, npar-1 do B(i) = -total(gv*d[*,*,i]*w1)

; Solving the linear equations
  svdc, A, ww, uu, vv
  pp = svsol(uu, ww, vv, B)
  par(*,ip)=pp+par(*,ip)

endelse


endfor


endfor

return, float(par)
end

