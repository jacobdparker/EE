pro ee_boxspectra
  common widget_environment, img, didx, tidx, mouseread
  common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map, goodmap, goodmap_1403
  common data, si_1394_index,si_1394_data,sjiindex,sjidata,si_1403_index, si_1403_data,fe_index,fe_data
  
;Find the ee files needed and restore fits filepaths
  eefiles=file_search('../EE_Data','ee_*.sav')
  restore, "ee_obs_paths.sav"
  nfiles=n_elements(eefiles)
  obstimes=file_search('../EE_Data','dateobs*.sav')

;Set the wrapper state - which file to start on?  
  if file_search('ee_wrapper_state.sav') eq "" then wrapper_state=0 else $
     restore, "ee_wrapper_state.sav"

  if wrapper_state ge nfiles then begin
     STOP, "All files already finished"
  endif
  
;Start loop 
  while wrapper_state lt nfiles  do begin
     print, "Restoring ee files..."
     restore, eefiles[wrapper_state]
     restore, obstimes[wrapper_state]
     restore,rasterdir+"goodmap1403_"+strmid(eefiles[wrapper_state],25,9)
     restor=1
     
;Send ee file and fits filepath to eerestore to despike and load data
     print, "Sending data to despike..."
     eerestore, ee_obs_path[wrapper_state], restor

;Make velocity axes
     print, "Beginning velocity analysis..."
     lambda0_1394=si_1394_index[0].wavelnth
     lambda0_1403=si_1403_index[0].wavelnth

     lambda_1394=si_1394_index[0].wavemin+si_1394_index[0].cdelt1*findgen(si_1394_index[0].naxis1)
     lambda_1403=si_1403_index[0].wavemin+si_1403_index[0].cdelt1*findgen(si_1403_index[0].naxis1)

     velocity_1394=3e5*(lambda_1394-lambda0_1394)/lambda0_1394 ;km/s
     velocity_1403=3e5*(lambda_1403-lambda0_1403)/lambda0_1403 ;km/s

;Find where to crop
     indices_1394=where((velocity_1394 le 150) AND (velocity_1394 ge -150))
     indices_1403=where((velocity_1403 le 150) AND (velocity_1403 ge -150))

     velocity_1394=velocity_1394(indices_1394)
     velocity_1403=velocity_1403(indices_1403)

     si_1394_data=si_1394_data(indices_1394,*,*)
     si_1403_data=si_1403_data(indices_1403,*,*)

;Free memory
     undefine, lambda0_1394
     undefine, lambda0_1403
     undefine, lambda_1394
     undefine, lambda_1403

;; ;Define axis limits for plots
;;      axmax=max([max(total_1d(si_1394_data,2)),max(total_1d(si_1403_data,2))])
;;      axmin=min([min(total_1d(si_1394_data,2)),min(total_1d(si_1403_data,2))])

;;      chiax=[5e7,4e6,0,3e10,3e6,0,8e6,2.5e7,1.5e9,4e7,2e8,2e9,4e8,1.2e8,1.8e4,3e5,5e7,4e8,6e8,1.2e8,0,4e8,4e8,1e9,1.5e8,0,3e8]
     
;Begin event loop
     count=mouseread.count
     for i=0,count do begin

        sz_1394=size(si_1394_data)
        sz_1403=size(si_1403_data)
        
        if (mouseread.x1[i] ge sz_1394[3]) then mouseread.x1[i]=sz_1394[3]-1
        if (mouseread.y1[i] ge sz_1394[3]) then mouseread.y1[i]=sz_1394[3]-1
        if ((mouseread.x0[i] eq mouseread.x1[i]) AND (mouseread.y0[i] eq mouseread.y1[i])) then continue
        if (mouseread.x0[i] ge mouseread.x1[i]) then mouseread.x0[i]=mouseread.x1[i]-1
        if (mouseread.y0[i] ge mouseread.y1[i]) then mouseread.y0[i]=mouseread.y1[i]-1
        if mouseread.x0[i] lt 0 then mouseread.x0[i]=0
        if mouseread.y0[i] lt 0 then mouseread.y0[i]=0
        
        print, "Iterating event number"+string([i])+" for observation"+string([wrapper_state])

                                ;Crop data arrays to time, slit
                                ;height, velocity at appropriate value
        current_1394_data=si_1394_data[indices_1394,$
                                       mouseread.y0[i]:mouseread.y1[i],$
                                       mouseread.x0[i]:mouseread.x1[i]]
        current_1403_data=si_1403_data[indices_1403,$
                                       mouseread.y0[i]:mouseread.y1[i],$
                                       mouseread.x0[i]:mouseread.x1[i]]

        
                                ;Collapse along slit
        current_1394_data=total_1d(current_1394_data,2)
        current_1403_data=total_1d(current_1403_data,2)

        
;Chi squared calculation at all observation times
        sz_1394=size(current_1394_data)
        sz_1403=size(current_1403_data)
        chisq=fltarr(sz_1394[2])

        print, "Calculating chi squared"
        
                                ;Just kidding, I had to make for loops :(
        if sz_1394[1] eq sz_1403[1] then begin
           for n=0,sz_1394[2]-1 do begin
              chisq[n]=total((current_1394_data[*,n]-2*current_1403_data[*,n])^2)
           endfor
        endif else begin
           larger=(sz_1394[1] lt sz_1403[1])
           if larger eq 1 then begin
;If 1403 is larger, then interpolate to fit 1394 grid
              for n=0,sz_1394[2]-1 do begin
                 int=interpol(current_1403_data[*,n],velocity_1403,velocity_1394)
                 chisq[n]=total((current_1394_data[*,n]-2*int)^2)
              endfor
           endif else begin
;Otherwise 1394 is larger and we interpolate to fit 1403 grid
              for n=0,sz_1394[2]-1 do begin
                 int=interpol(current_1394_data[*,n],velocity_1394,velocity_1403)
                 chisq[n]=total((int-2*current_1403_data[*,n])^2)
              endfor
           endelse
        endelse

;Plot 1394 and 1403 lines against each other and save
        p1=plot(velocity_1394, current_1394_data, '-r',/widgets)
        p1.title="Wavelength 1394A and 1403A as a function of velocity"+string(wrapper_state)
        p1.xtitle="Velocity (km/s)"
        p1.ytitle="Intensity"
        p1=plot(velocity_1403, current_1403_data, '-b',/overplot)
        p1.save, rasterdir+"linplot_"+strmid(eefiles[wrapper_state],25,5)+"_"+strcompress(string(i),/remove_all)+".png", resolution=300, border=10
        p1.close
        
;Plot and save chi squared as a function of time (index) to EE_Data directory
        indices=findgen(mouseread.x1[i]-mouseread.x0[i], start=mouseread.x0[i])
        p2=plot(indices, chisq, 'r')
        p2.title="Chi squared as a function of time"+string(wrapper_state)
        p2.xtitle="Index (Starting from event start)"
        p2.ytitle="Chi squared"
        p2.save, rasterdir+"chisq_"+strmid(eefiles[wrapper_state],25,5)+"_"+strcompress(string(i),/remove_all)+".png", resolution=300, border=10
        p2.close
        
     endfor
     
     
;Remove fits files & clear memory so we can save plots if needed
     ee_dataclear, ee_obs_path[wrapper_state]

;Determine whether to continue

     wrapper_state++
     save, wrapper_state, file="ee_wrapper_state.sav"
     print, "Continuing on to iteration number"+string([wrapper_state])
  endwhile
     
end
