

function jul2str, time, hr_only=hr_only

  str=string(time, f='(c(CDI, "-", CMoA, "-", CYI, x, CHI02, ":", CMI02, ":", CSI02, x, "UT"))')
  if n_elements(hr_only) then str = strmid(str, 12, 20) 
  return, str

end