function aia_lct_fun, wave
  if n_elements(wave) eq 0 then wave = 171
  aia_lct, rr, gg, bb, wave=wave
  return, [[rr], [gg], [bb]]
end