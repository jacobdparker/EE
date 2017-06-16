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
;  timefiles=filepaths leading to actual observation times
;  char=character variable for plot/computation selection
;SAVES: Plots are saved into a directory containing time plots (TBA)
;AUTHOR(S): A.E. Bartz, 6/9/17
pro ee_timestats, dat_array, dates, counts, errbars=errbars
;Initialize arrays & find observation time filepaths
  depth=n_elements(counts)
  lengths=fltarr(100,depth)
  avg_lens=fltarr(depth)
  dev_lens=fltarr(depth)
  avg_height=fltarr(depth)
  heights=fltarr(100,depth)
  timefiles=file_search('../EE_Data','dateobs*.sav')
  
;Compute arrays containing each event's length and the average length
  for obs=0,depth-1 do begin
     x0=dat_array[*,0,obs]
     x1=dat_array[*,1,obs]
     y0=dat_array[*,2,obs]
     y1=dat_array[*,3,obs]
     
;Crop data arrays to actual number of events to omit extra zeroes
     x0=x0[0:counts[obs]]
     x1=x1[0:counts[obs]]
     y0=y0[0:counts[obs]]
     y1=y1[0:counts[obs]]
     
;Compute average length of time of events and standard deviations     
     obs_lens=ee_boxlength(x0,x1,timefiles[obs])
     avg_lens[obs]=mean(obs_lens)
     dev_lens[obs]=stddev(obs_lens)
     lengths[0,obs]=obs_lens
     heights[0,obs]=y1-y0
  endfor

;Free memory
  x0=!null
  x1=!null
  y0=!null
  y1=!null
  obs_lens=!null
  
;Compute & print average length of time for all events
  print, "The average time of an event for all observations is "+$
         strcompress(mean(avg_lens),/Remove_all)+' hours with standard '+$
         'deviation of '+strcompress(stddev(avg_lens),/remove_all)+' hours'

;User interactive: Which plots do you want to produce?
  i=0
  while i eq 0 do begin
     
     char=''
     print, format='(%"Which plot do you want to produce?")'
     print, format='(%"a - average box time length of each observation\nc - cumulative histogram of time vs number of plots drawn\nl - time length of all boxes in all observations\nq - quit and return to kernel")'
     read, char, prompt='Type your selection here: '

     case char of
        'a': begin
;Plot the average width of each box
           
        end

        'l': begin
;Plot the length of each box against date,toggle with/without error bars
           b=plot(make_array(counts[0],value=dates[0]), lengths[0:counts[0],0], $
                  /WIDGETS, symbol='o', /sym_filled, linestyle=6, $
                  rgb_table=43,sym_transparency=50,$
                  xrange=[dates[0]-50,dates[-1]+50], xtickinterval=365, $
                  xtitle='Julian date',ytitle='Hours',$
                  title='Time length of all event boxes')
           for n=1,31 do begin
              b=plot(make_array(counts[n],value=dates[n]), lengths[0:counts[n],n], $
                            symbol='o', /sym_filled, rgb_table=43, linestyle=6,$
                            sym_transparency=50,/OVERPLOT)
           endfor
        end

        'q': i=1

        else: print, "Invalid input."
     endcase
  endwhile
  print, 'Returning to kernel...'
end
