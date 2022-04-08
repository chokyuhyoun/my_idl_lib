pro setdata, ng_graphic, arg1, arg2, arg3
  min = ng_graphic.min
  max = ng_graphic.max
  ng_graphic.refresh, /disable
  arg1 = reform(temporary(arg1))
  sz = size(arg1)
  case n_params() of 
    2 : begin
        ng_graphic.setdata, arg1, findgen(sz[1])-0.5, findgen(sz[2])-0.5
        end
    4 : begin
        dx = arg2[1]-arg2[0]
        dy = arg3[1]-arg3[0]
        x1 = arg2-0.5*dx
        y1 = arg3-0.5*dy
        ng_graphic.setdata, arg1, x1, y1
        end     
  endcase
  ng_graphic.min_value = min
  ng_graphic.max_value = max
  ng_graphic.refresh
end