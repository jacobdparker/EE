;PROGRAM: ee_timedist
;PURPOSE:
; 1. Compute length of time of each boxed event from eemouse
; 2. Compute average length of time for all events
; 3. Compute average length of time of event for each observation and plot
; 4. Plot each event against its date such that the size of the dot
; corresponds to the length of the event
; 5. Save plots to a directory of time plots
;PARAMETERS:
;  dat_array=4x100x29 array containing dimension data for event boxes
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
;RETURNS: N/A
;SAVES: Plots are saved into a directory containing time plots (TBA)
;AUTHOR(S): A.E. Bartz, 6/9/17
pro ee_timestats, dat_array, dates, counts

  depth=n_elements(counts)
  lengths=fltarr(100,depth)
  avg_lens=fltarr(depth)
  dev_lens=fltarr(depth)
  
  ;Compute arrays containing each event's length and the average length
  for obs=0,depth-1 do begin
     x0=dat_array[*,0,obs]
     x1=dat_array[*,1,obs]

     x0=x0[0:counts[obs]]
     x1=x1[0:counts[obs]]
     ;The absolute value is because some boxes were drawn backwards
     ;(Better to be safe than sorry!)
     lengths[obs]=abs(x1-x0)
     avg_lens[obs]=mean(abs(x1-x0))
     dev_lens[obs]=stddev(abs(x1-x0))
  endfor

  ;Compute & print average length of time for all events
  print, "The average time of an event for all observations is ", mean(avg_lens)
  print, "The standard deviation of time of all observations is ", stddev(avg_lens)

  ;Plot the average length of each observation, with error bars
  ;bar_plot, avg_lens[0:18], barnames=string(dates[0:18]), $
  ;          title='Fuck you, IDL', /ROTATE   
  ;errplot, string(dates[0:18]), avg_lens[0:18]-dev_lens[0:18], $
  ;          avg_lens[0:18]+dev_lens[0:18], /OVERPLOT

  b=barplot(dates, avg_lens) ;This should throw the same error as emailed
  
end
