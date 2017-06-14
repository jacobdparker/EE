;PROGRAM: ee_ystats
;PURPOSE:
; 1. Compute spatial distribution of each boxed event from eemouse
; 2. Compute average physical width for all events
; 3. Compute average physical width of event for each observation and plot
; 4. Plot each event against its date such that the size of the dot
; corresponds to the physical width of the event
; 5. Save plots to a directory of width plots
;PARAMETERS:
;  dat_array=4x100x29 array containing dimension data for event boxes
;  dates=array of Julian dates of each observation
;  count=array of number of boxes on each image
;VARIABLES:
;  depth=number of observations
;  widths=2D array of lengths of each event in each observation
;  avg_wids=array of average width of an event during each
;  observation
;  dev_wids=array of standard deviations of widths of each event
;  during each observation
;  obs=counting variable
;  y0,y1=temporary arrays containing top and bottom position
;SAVES: Plots are saved into a directory containing width plots (TBA)
;AUTHOR(S): A.E. Bartz, 6/12/17

pro ee_ystats, dat_array, dates, counts

;Initialize arrays
  depth=n_elements(counts)
  widths=fltarr(100,depth)
  avg_wids=fltarr(depth)
  dev_wids=fltarr(depth)

;Compute arrays containing each event's width and the average width
  for obs=0,depth-1 do begin
     y0=dat_array[*,2,obs]
     y1=dat_array[*,3,obs]

;Crop data arrays to actual number of events to omit extra zeroes
     y0=y0[0:counts[obs]]
     y1=y1[0:counts[obs]]
     
;Absolute value due to some boxes drawn backwards
     widths[obs]=abs(y1-y0)
     avg_wids[obs]=mean(abs(y1-y0))
     dev_wids[obs]=stdev(abs(y1-y0))
  endfor

;Compute & print average length of time for all events
  print, "The average physical width of an event for all observations is "+$
         strcompress(mean(avg_wids), /remove_all)+$
         " units and the standard deviation is "+$
         strcompress(stddev(avg_wids), /remove_all)+" units"
  
;Plot the average width of each observation with or without error bars
  plot, dates, avg_wids,$
        title='Average width of event at all observations', $
        XTITLE='Julian date', YTITLE='Average width of an event (unit)',$
        psym=1
  ;errplot, dates, avg_wids-dev_wids, avg_wids+dev_wids, /OVERPLOT
  
end

