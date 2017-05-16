;Take in IRIS O I raster data and caculate an FUV wavelength offset

function wave_cal,data,index
 
  raster_size= size(data)
  wavemin = index[0].wavemin
  wavemax = index[0].wavemax
  wavesz = raster_size[1]
  lambda = wavemin + index[0].cdelt1*findgen(index[0].naxis1) ;wavelength axis, Angstroms
  lambda0 = index.wavelnth ;central wavelength 

  profile = total(data,2)
  lambda_shift = fltarr(raster_size[3])
  for i= 0,raster_size[3]-1 do begin
     if total(profile[*,i]) eq 0 then lambda_shift[i]=0 else begin
        g = gauss_fit(lambda,profile[*,i],a)
        lambda_shift[i]=a[4]-lambda0[i]
     endelse
     
     
  endfor
  
  return, lambda_shift
  


end
