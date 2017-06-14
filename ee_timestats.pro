;PROGRAM: ee_timestats
;PURPOSE:
; 1. Compute length of time of each boxed event from eemouse
; 2. Compute average length of time for all events
; 3. Compute average length of time of event for each observation and plot
; 4. Plot each event against its date such that the size of the dot
; corresponds to the length of the event
; 5. Save plots to a directory of time plots
;PARAMETERS:
;  dat_array=4x100x31 array containing dimension data for event boxes
;  dates=array of Julian dates of each observation
;  counts=array of number of boxes in each image
;VARIABLES:
;  depth=number of observations
;  lengths=2D array of lengths of each event in each observation
;  avg_lens=array of average length of time of an event during each
;     observation
;  dev_lens=array of standard deviations of lengths of each event
;     during each observation
;  obs=counting variable
;  x0,x1=temporary arrays containing beginning and ending time
;SAVES: Plots are saved into a directory containing time plots (TBA)
;AUTHOR(S): A.E. Bartz, 6/9/17
pro ee_timestats, dat_array, dates, counts
;Initialize arrays & find observation time filepaths
  depth=n_elements(counts)
  lengths=fltarr(100,depth)
  avg_lens=fltarr(depth)
  dev_lens=fltarr(depth)
  timefiles=file_search('../EE_Data','dateobs*.sav')
  
;Compute arrays containing each event's length and the average length
  for obs=0,depth-1 do begin
     x0=dat_array[*,0,obs]
     x1=dat_array[*,1,obs]
     
;Crop data arrays to actual number of events to omit extra zeroes
     x0=x0[0:counts[obs]]
     x1=x1[0:counts[obs]]

;Compute average length of time of events and standard deviations     
     obs_lens=ee_boxlength(x0,x1,timefiles[obs])
     avg_lens[obs]=mean(obs_lens)
     dev_lens[obs]=stddev(obs_lens)
     lengths[obs]=obs_lens
  endfor

  ;Compute & print average length of time for all events
  print, "The average time of an event for all observations is "+$
         strcompress(mean(avg_lens),/Remove_all)+' hours with standard '+$
         'deviation of '+strcompress(stddev(avg_lens),/remove_all)+' hours'


;Plot the average length of each observation, with/without error bars

  plot, dates, avg_lens,$
        title='Average length of time event at all observations',$
        XTITLE='Julian date',YTITLE='Average length of an event (hours)',$
        psym=1
  ;errplot, dates, avg_lens-dev_lens, avg_lens+dev_lens, /OVERPLOT

  ;STOP
  ;b=barplot(dates, avg_lens) ;This should throw the same error as emailed
  
end
