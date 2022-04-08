function func, x
    x=double(x)
    r=execute('result='+func)
    return, result
end


function integration, func, a, b, order=order, silent=silent

    if n_elements(order) eq 0 then begin
        j_f=8
    endif else begin
        j_f=round(order/2.)    
    endelse    
   
    if n_elements(silent) eq 0 then silent=0 

    h=double(b)-double(a)
    t=dblarr(j_f+1,j_f+1) 
    t[1, 1]=0.5*h*(f(func, a)+f(func, b))
    for j=1, j_f do begin
        s=0.
        if j gt 1 then begin
            for l=1, 2^(j-2) do s=s+f(func, a+(2.*l-1.)*h)
            t[j, 1]=0.5*t[j-1, 1]+h*s
        endif
        for k=2, j do t[j, k]=t[j, k-1]+(t[j, k-1]-t[j-1, k-1])/(4.^(k-1)-1.)
        h=h/2.
    endfor

    if silent eq 0 then begin 
        print, 'result ='+strcompress(string(t[j_f, j_f]))
    endif
    return, t[j_f, j_f]
end