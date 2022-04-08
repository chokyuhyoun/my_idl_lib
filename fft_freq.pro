function fft_freq, t, center=center
  if n_elements(center) eq 0 then center=0
  dt=t[1]-t[0]
  n=n_elements(t)
  X = FINDGEN((N - 1)/2) + 1
  is_N_even = (N MOD 2) EQ 0
  if (is_N_even) then begin
    freq = [0.0, X, N/2, -N/2 + X]/(N*dT)
    if center then freq = shift(freq, 0.5*n_elements(freq)) 
  endif else begin
    freq = [0.0, X, -(N/2 + 1) + X]/(N*dT)
    if center then freq = shift(freq, 0.5*n_elements(freq)-1)
  endelse
  return, freq
end  
  
  