pro IRIS_MOSAIC_DOPPLER, r, g, b, $
	make = make, load = load

;+
;
; Routine to load Scott McIntosh's Doppler color table
;
;
;-

if KEYWORD_SET(make) then begin
	; This is how the values in the body of the routine were extracted from 
	; the .sav file
	RESTORE, file = 'NEW_DOPPLER.SAV', /verb
	rrr = STRJOIN(STRING(r,form = '(i03)'), ', ', /single)
	ggg = STRJOIN(STRING(g,form = '(i03)'), ', ', /single)
	bbb = STRJOIN(STRING(b,form = '(i03)'), ', ', /single)
	PRINT, 'r = BYTE([' + rrr + '])'
	PRINT, 'g = BYTE([' + ggg + '])'
	PRINT, 'b = BYTE([' + bbb + '])'	
endif

r = BYTE([255, 001, 002, 002, 002, 003, 003, 004, 004, 005, 006, 006, 007, 007, 008, 009, 010, 010, 011, 012, 013, 014, 015, 016, 017, 018, 019, 020, 021, 022, 024, 025, 026, 027, 029, 030, 031, 033, 034, 036, 037, 039, 040, 042, 043, 045, 047, 048, 050, 052, 054, 055, 057, 059, 061, 063, 065, 067, 069, 071, 073, 075, 077, 079, 082, 084, 086, 088, 091, 093, 096, 098, 100, 103, 105, 108, 110, 113, 116, 118, 121, 124, 126, 129, 132, 135, 138, 141, 144, 147, 150, 153, 156, 159, 162, 165, 168, 171, 174, 178, 181, 184, 188, 191, 194, 198, 201, 205, 208, 212, 216, 219, 223, 226, 230, 234, 238, 241, 245, 249, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 000])
g = BYTE([255, 001, 002, 002, 002, 003, 003, 004, 004, 005, 006, 006, 007, 007, 008, 009, 010, 010, 011, 012, 013, 014, 015, 016, 017, 018, 019, 020, 021, 022, 024, 025, 026, 027, 029, 030, 031, 033, 034, 036, 037, 039, 040, 042, 043, 045, 047, 048, 050, 052, 054, 055, 057, 059, 061, 063, 065, 067, 069, 071, 073, 075, 077, 079, 082, 084, 086, 088, 091, 093, 096, 098, 100, 103, 105, 108, 110, 113, 116, 118, 121, 124, 126, 129, 132, 135, 138, 141, 144, 147, 150, 153, 156, 159, 162, 165, 168, 171, 174, 178, 181, 184, 188, 191, 194, 198, 201, 205, 208, 212, 216, 219, 223, 226, 230, 234, 238, 241, 245, 249, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 253, 249, 245, 241, 238, 234, 230, 226, 223, 219, 216, 212, 208, 205, 201, 198, 194, 191, 188, 184, 181, 178, 174, 171, 168, 165, 162, 159, 156, 153, 150, 147, 144, 141, 138, 135, 132, 129, 126, 124, 121, 118, 116, 113, 110, 108, 105, 103, 100, 098, 096, 093, 091, 088, 086, 084, 082, 079, 077, 075, 073, 071, 069, 067, 065, 063, 061, 059, 057, 055, 054, 052, 050, 048, 047, 045, 043, 042, 040, 039, 037, 036, 034, 033, 031, 030, 029, 027, 026, 025, 024, 022, 021, 020, 019, 018, 017, 016, 015, 014, 013, 012, 011, 010, 010, 009, 008, 007, 007, 006, 006, 005, 004, 004, 003, 003, 002, 002, 002, 001, 000, 000])
b = BYTE([254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 253, 249, 245, 241, 238, 234, 230, 226, 223, 219, 216, 212, 208, 205, 201, 198, 194, 191, 188, 184, 181, 178, 174, 171, 168, 165, 162, 159, 156, 153, 150, 147, 144, 141, 138, 135, 132, 129, 126, 124, 121, 118, 116, 113, 110, 108, 105, 103, 100, 098, 096, 093, 091, 088, 086, 084, 082, 079, 077, 075, 073, 071, 069, 067, 065, 063, 061, 059, 057, 055, 054, 052, 050, 048, 047, 045, 043, 042, 040, 039, 037, 036, 034, 033, 031, 030, 029, 027, 026, 025, 024, 022, 021, 020, 019, 018, 017, 016, 015, 014, 013, 012, 011, 010, 010, 009, 008, 007, 007, 006, 006, 005, 004, 004, 003, 003, 002, 002, 002, 001, 000, 000])

if KEYWORD_SET(load) then TVLCT, r, g, b

end