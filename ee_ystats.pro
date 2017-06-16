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
;  obs,i=counting variable
;  y0,y1=temporary arrays containing top and bottom position
;SAVES: Plots are saved into a directory containing width plots (TBA)
;AUTHOR(S): A.E. Bartz, 6/12/17

pro ee_ystats, dat_array, dates, counts

;Initialize arrays
  depth=n_elements(counts)
  widths=fltarr(100,depth)
  avg_wids=fltarr(depth)
  dev_wids=fltarr(depth)

;Compute arrays containing each event's width and the average height
  for obs=0,depth-1 do begin
     y0=dat_array[*,2,obs]
     y1=dat_array[*,3,obs]

;Crop data arrays to actual number of events to omit extra zeroes
     y0=y0[0:counts[obs]]
     y1=y1[0:counts[obs]]
     
;Absolute value due to some boxes drawn backwards
     widths[obs]=y1-y0
     avg_wids[obs]=mean(y1-y0)
     dev_wids[obs]=stdev(y1-y0)
  endfor

;Free memory 
  y1=!null
  y2=!null
  
;Compute & print average length of time for all events
  print, "The average physical height of an event for all observations is "+$
         strcompress(mean(avg_wids), /remove_all)+$
         " units and the standard deviation is "+$
         strcompress(stddev(avg_wids), /remove_all)+" units"

;Let user decide which plots they want to generate
  i=0
  while i eq 0 do begin

     char=''
     print, "Which plot do you want to produce?"
     print, format='(%"a - average box physical height of each observation\nh - physical box height for all boxes\nq - quit and return to kernel")'
     read, char, prompt="Type your selection here: "

     case char of
        'a': begin
;Plot the average width of each observation with or without error bars
           p=plot(dates, avg_wids, title="Average height of event boxes", $
                  xtitle="Julian date", /sym_filled, linestyle=6, $
                  YTITLE="Average height of events (pixels)", $
                  /WIDGETS, sym_transparency=50, symbol='o', $
                  rgb_table=43, xrange=[dates[0]-50,dates[0]+50], $
                  xtickinterval=365)
        end

        'h': begin
           p=plot(make_array(counts[0],value=dates[0]),widths[0:counts[0],0], $
                  /WIDGETS, symbol='o', /sym_filled, linestyle=6, $
                  xtickinterval=365, xrange=[dates[0]-50,dates[0]+50], $
                  rgb_table=43, xtitle="Julian date", $
                  ytitle="Actual height of events (pixels)")
           for n=1,31 do begin
              p=plot(make_array(counts[n],value=dates[n]), $
                     widths[0:counts[n],n], symbol=0, /sym_filled, $
                     rgb_table=43, linestyle=6, sym_transparency=50, $
                     /OVERPLOT)
           endfor
        end

        'q': i=1

        else: print, "Invalid input."
     endcase
  endwhile
  
  print, "Returning to kernel."     
end

