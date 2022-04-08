function ticks_exponents, axis, index, value
  return, '10!u'+string(floor(alog10(value)), f='(i0)')+'!n'
end
