;NAME:
;  eecolors
;
;PURPOSE:
;; Take an ee.sav file and map line profile shape with some
;; interesting color profile

;CALLING SEQUENCE:
;  eemovie, [/mencoder]
;
;INPUT PARAMETERS:
;  n/a
;
;KEYWORDS:
;  
;MODIFICATION HISTORY:


pro eecolors,ee_event

w = getwindows()
  if n_elements(w) gt 1 then begin
     for i = 0,n_elements(w)-1 do w(i).close
  endif
  
  common widget_environment, img, didx, tidx, mouseread
  common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map
  common data, rasterindex,rasterdata,sjiindex,sjidata

 

  raster_size= size(rasterdata)
  x0 = mouseread.x0[ee_event]
  x1 = mouseread.x1[ee_event]
  y0 = mouseread.y0[ee_event]
  y1 = mouseread.y1[ee_event]
  wavemin = rasterindex[x0].wavemin
  wavemax = rasterindex[x0].wavemax
  wavesz = raster_size[1]
  wavedelta = (wavemax-wavemin)/wavesz
  wavelength = [wavemin:wavemax:wavedelta]

  doppler_shift = 299792.458*(wavelength-rasterindex[x0].wavelnth)/rasterindex[x0].wavelnth
  STOP
  linecenter = max(where(wavelength lt rasterindex[x0].wavelnth))+1

  ;slit = image(rasterdata[*,y0:y1,x0+frame])
  ;slit.xr = [linecenter-10,linecenter+10]

  time = x1-x0
  
  
 
for i = 1,time-1 do begin
   
   ;; con = surface(rasterdata[*,y0:y1,x0+i],/current)
   ;; con.refresh,/disable
   ;; con.rotate,/reset
   ;; con.rotate,-90, /xaxis
   ;; con.xr = [linecenter-20,linecenter+20]
   
   ;; con.refresh
   surface,rasterdata[*,y0:y1,x0+i],doppler_shift,[y0:y1],xr=[linecenter-20,linecenter+20]
   wait,.125
   ;con.erase
   
end

  
end
