;+
; :Description:
;    Create IDL Polygon graphic.
;
; :Params:
;    Points : 
;
; :Keywords:
;    _REF_EXTRA
;
;-
function polygon_alpha, X, Y, Z, styleIn, $
  DATA=data, DEVICE=device, NORMAL=normal, $
  POSITION=position, $
  RELATIVE=relative, TARGET=target, $
  TEST=test, $
  DEBUG=debug, VISUALIZATION=add2vis, alpha=alpha, $
  _REF_EXTRA=ex

  compile_opt idl2, hidden
@graphic_error

  nparams = n_params()
  if (isa(X, 'STRING')) then begin
    MESSAGE, 'Style argument must be passed in after data.'
  endif
  if (isa(Y, 'STRING'))  then begin
    if (nparams gt 2) then $
      MESSAGE, 'Style argument must be passed in after data.'
    style = Y
    nparams--  
  endif
  if (isa(Z, 'STRING')) then begin
    if (nparams gt 3) then $
      MESSAGE, 'Style argument must be passed in after data.'
    style = Z
    nparams--
  endif
  if (isa(styleIn, 'STRING')) then begin
    style = styleIn
    nparams--
  endif
  
  if (n_elements(style)) then begin
    style_convert, style, COLOR=color, LINESTYLE=linestyle, THICK=thick
  endif
  
  if (KEYWORD_SET(test)) then begin
    x = [0.25,0.75,0.75,0.25]
    y = [0.25,0.25,0.75,0.75]
    nparams = 2
  endif

  nx = N_ELEMENTS(x)

  case nparams of
    1 : begin
      if ((SIZE(x, /N_DIMENSIONS) eq 2) && (nx ge 6)) then begin
        dims = SIZE(x, /DIMENSIONS)
        ind2 = where(dims eq 2, cnt2)
        ind3 = where(dims eq 3, cnt3)
        if (cnt2 eq 1) then begin
          points = x
          if (ind2 eq 1) then $
            points = TRANSPOSE(points)
        endif
        if (cnt3 eq 1) then begin
          points = x
          if ((ind3 eq 1) && (ind2 ne 0)) then $
            points = TRANSPOSE(points)
        endif
        if (cnt3 eq 2) then begin
          points = x
        endif
      endif
    end
    2 : if (nx gt 2) then $
      points = TRANSPOSE([[x],[y]]) 
    3 : begin
        if (nx gt 2) then begin
          points = (N_ELEMENTS(z) gt 1) ? TRANSPOSE([[x],[y],[z]]) : $
            TRANSPOSE([[x],[y],[REPLICATE(z, nx)]])
        endif
      end
    else : MESSAGE, 'Incorrect number of arguments.'
  endcase
  
  if (N_ELEMENTS(points) eq 0) then $
    MESSAGE, 'Must have three or more points.'

  ; Check for unknown or illegal properties.
  if (N_ELEMENTS(ex) gt 0) then $
    Graphic, _EXTRA=ex, ERROR_CLASS='Polygon', /VERIFY_KEYWORDS

  if (KEYWORD_SET(data) && ~ISA(add2vis)) then add2vis = 1b
  iPolygon, points, $
    DATA=data, DEVICE=device, NORMAL=normal, RELATIVE=relative, TARGET=target, $
    OBJECT=oPolygon, VISUALIZATION=add2vis, SHADING=1, $
    COLOR=color, LINESTYLE=linestyle, THICK=thick, _EXTRA=ex

  ; Ensure that all class definitions are available.
  Graphic__define
  if n_elements(alpha) eq 0 then alpha=0
  oGraphic = OBJ_NEW('Polygon', oPolygon, alpha_channel=alpha)

  if (ISA(position)) then begin
    oGraphic->_SetProperty, POSITION=position, DEVICE=device
  endif

  return, oGraphic
  
end
