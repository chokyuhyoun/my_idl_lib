function gaussian_, x, p
  return, p[0]*exp(-0.5*((x-p[1])/p[2])^2.) + p[3]
end
