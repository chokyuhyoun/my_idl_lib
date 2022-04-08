;+
;  Name: BISECTOR
;  Purpose:
;              measure the bisector value
;  Calling sequence:
;              bisector_pos = bisector(wv, sp, int, equi_int_left, equi_int_right)
;  Inputs
;           wv      array of wavelengths in angstrom
;           sp      spectrogram to be corrected
;           int     criteria intensity to perform the bisector method    
;           
;  Output:
;           bisector value in angstrom
;  Optional input
;           silent  turn off the error message
;  Optional output
;           equi_int_left, equi_int right
;                   red/blue wavelength to be used for bisector method
;  History:
;      2012 February : K. Cho first coded
;-

function bisector, wv, sp, int, left=left, right=right, silent=silent

sp1=sp-int
med_val=sp1[0:-2]*sp1[1:-1]
cross=where(med_val lt 0.)
core=(where(sp eq min(sp)))[0]
if n_elements(cross) lt 2 then return, -9999.
l=(cross[where(cross le core)])[-1]
r=(cross[where(cross ge core)])[0]
left=wv[l]+(wv[l+1]-wv[l])/(sp1[l+1]-sp1[l])*sp1[l]
right=wv[r]+(wv[r+1]-wv[r])/(sp1[r+1]-sp1[r])*sp1[r]
bisector_pos=0.5*(left+right)
;stop
return, bisector_pos 
end   



path='/data/home/chokh/110929/align_ex/fiss/align'
out_path=path+'/doppler'
file_mkdir, out_path
cd, path
f=file_search('*A1*.fts')
for i=4, n_elements(f)-1 do begin
    i=n_elements(f)-1
    cd, path
    print, f[i]
    dot_pos=strpos(f[i], '.', /reverse_search)
    dum=strsplit(f[i], '.', /extract)
;    name=strcompress(dum[0]+'_doppler.sav', /remove_all)
;    stop
    ha_data=readfits(f[i], h, /sil)
    sz=size(ha_data)
    wv=fiss_wv(f[i])
    dop_data=fltarr(sz[2], sz[3])
;    for int=1500, 2500, 100 do begin
        for j=0, sz[2]-1 do begin
    ;        j=221
            raw_sp=reform(ha_data[*, j, *])
            sp=fiss_tell_rm_kh(wv+6562.817d, raw_sp, par, nofit=0)
            for k=0, sz[3]-1 do begin
    ;            k=141
;                int=2178.63
                dop_data[j, k]=bisector(wv, sp[*, k], int, /sil)
    ;            dop_data[*, k]=bisector_d(wv, sp, hdlvalue, int, wvinput=0)
    ;            stop
            endfor
        endfor
        fiss2map_n, ha_data, h, fiss_map
        doppler_map=fiss_map
        doppler_map.data=fiss_embed(dop_data*!c0*1d-5/6562.817d, h, background=-9999)
        doppler_map.id='Doppler '+string(int, f='(i4)')         
        name=strcompress(dum[0]+'_doppler_'+string(int, f='(i4)')+'.sav', /remove_all)                 
        cd, out_path
        save, doppler_map, filename=name
    endfor
;    stop
endfor    
end 