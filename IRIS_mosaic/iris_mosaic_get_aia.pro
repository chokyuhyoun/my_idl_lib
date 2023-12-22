pro IRIS_MOSAIC_GET_AIA, start_time, end_time, wave, ofolder, $
	remote = remote

;+
;
;
;
;
;-

if N_ELEMENTS(remote) eq 0 then remote = 0

a = VSO_SEARCH(start_time, end_time, instr = 'aia', wave = wave, /url)

if not(isarray(a)) then goto, skip

sock_copy, a[0].url, err=err, out_dir = ofolder

skip:

end
