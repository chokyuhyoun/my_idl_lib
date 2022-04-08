;+
; :Description:
;    Generate map structure for IRIS SJI
;
; :Params:
;    filename
;    h1
;    map
;
;
;
; :Author: chokh
;-
pro iris2map, filename, h1, map
  case n_params() of 
    2 : begin
        read_iris_l2, filename, h1, data
        end

    3 : begin
        data=filename
        h=h1
        end

    else : begin
    print, 'Syntax : iris2map, filename(or data array), map, [header,], wv=wv'
    end
  endcase                      
  index2map, h, data, map
  map.id=h[0].telescop+' '+h[0].tdesc1
  if n_params() eq 2 then h1=map
 
end