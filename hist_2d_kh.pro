function hist_2d_kh, data1, data2, loc1=loc1, loc2=loc2, plot=plot, bin=bin
  if n_elements(plot) eq 0 then plot = 0
  if n_elements(bin) eq 0 then bin = 0
  if ~bin then begin 
    nbin1 = 50
    bin1 = (max(data1)-min(data1))/(nbin1-1.)
    max1 = max(data1)
    min1 = min(data1)
    loc1 = [min1:max1:bin1]
  endif else begin
    nbin1 = n_elements(loc1)
    bin1 = mean(loc1[1:*] - loc1[0:-2])*1d
    max1 = loc1[-1]*1d
    min1 = loc1[0]*1d
    if floor((max1-min1)/bin1)+1l ne n_elements(nbin1) then max1 = max1 + 0.5*bin1
  endelse    
  if ~bin then begin
    nbin2 = 50
    bin2 = (max(data2)-min(data2))/(nbin2-1.)
    max2 = max(data2)
    min2 = min(data2)
    loc2 = [min2:max2:bin2]
  endif else begin
    nbin2 = n_elements(loc2)
    bin2 = mean(loc2[1:*] - loc2[0:-2])
    max2 = loc2[-1]
    min2 = loc2[0]  
    if floor((max2-min2)/bin2)+1l ne n_elements(nbin2) then max2 = max2 + 0.5*bin2
  endelse
  h2d = hist_2d(data1, data2, bin1=bin1, bin2=bin2, min1=min1, min2=min2, max1=max1, max2=max2)
;  stop
  if plot then _im123 = image_kh(h2d, loc1, loc2)
  return, h2d  
end