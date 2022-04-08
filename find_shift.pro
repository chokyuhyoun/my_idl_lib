function find_shift, obj, ref
  sz1=size(obj)
  sz2=size(ref)
  if total(sz1-sz2) ne 0 then begin
    print, 'Incompatbile Images : find_shift'
    return, [0,0.]
  endif

  f1=fft(ref, -1)
  f2=fft(obj, -1)
  ratio=conj(f1)*f2/abs(f1*f2)
  inv_r=float(fft(ratio, 1))
  m=max(inv_r, pos1)
  pos22=array_indices(inv_r, pos1)
  cc=(shift(inv_r, -pos22[0]+1, -pos22[1]+1))[0:2, 0:2]
  x1=(cc[0, 1]-cc[2, 1])/(cc[2, 1]+cc[0, 1]-2.*cc[1, 1])*.5
  y1=(cc[1, 0]-cc[1, 2])/(cc[1, 2]+cc[1, 0]-2.*cc[1, 1])*.5
  pos2=pos22+[x1, y1]
  
  if pos2[0] gt sz1[1]*0.5 then pos2[0]=pos2[0]-sz1[1]
  if pos2[1] gt sz1[2]*0.5 then pos2[1]=pos2[1]-sz1[2]
;  stop
  return, float(pos2)
end