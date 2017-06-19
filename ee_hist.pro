;PROCEDURE: ee_hist
;PURPOSE: create assorted histograms for IRIS data
;PARAMETERS:
;VARIABLES:
;PRODUCES:
;AUTHOR(S): A.E. Bartz 6/19/17

pro ee_hist, dat_array, dates, counts

  depth=n_elements(counts)
  lengths=fltarr(100,depth)
  heights=fltarr(100,depth)
  timefiles=file_search('../EE_Data','dateobs*.sav')
  
;Assign data arrays
  for obs=0,depth-1 do begin
     x0=dat_array[*,0,obs]
     x1=dat_array[*,1,obs]
     y0=dat_array[*,2,obs]
     y1=dat_array[*,3,obs]

;Crop data arrays to actual number of events
     x0=x0[0:counts[obs]]
     x1=x1[0:counts[obs]]
     y0=y0[0:counts[obs]]
     y1=y1[0:counts[obs]]

;Send data into larger arrays
     obs_lens=ee_boxlength(x0,x1,timefiles[obs])
     lengths[0,obs]=obs_lens
     heights[0,obs]=y1-y0
  endfor

  countsum=fltarr(depth)
  countsum[0]=counts[0]
  for obs=1,depth-1 do countsum[obs]=countsum[obs-1]+counts[obs]
  
;Histograms: which to produce?
  i=0
  while i eq 0 do begin

     char=''
     print, format='(%"\nHISTOGRAMS\nWhich plot do you want to produce?")'
     print, format='(%"c - cumulative histogram of time vs number of boxes drawn\ng - gaussian fit of cumulative histogram derivative\nq - quit and return to kernel")'
     read, char, prompt="Type your selection here: "

     case char of
        'c': begin
           ;Plot julian date versus counts
           p=plot(countsum,dates,/WIDGETS,ytitle="Julian date",$
                  xtitle="Number of boxes drawn",$
                  title="Cumulative histogram of time vs number of boxes drawn")
        end

        'g': begin
           ;Calculate and plot derivative
           dt=deriv(countsum,dates)
           sigd=derivsig(countsum,dates,0,0.1)
           p=plot(countsum,dt,/WIDGETS,ytitle="dt/dx",$
                  xtitle="Number of boxes drawn",$
                  title="Cumulative histogram derivative")
           ;Calculate gaussian fit, width of peak, and add to plot
           gauss=gaussfit(countsum,dt,yerror=yerror,sigma=sigma,nterms=6,$
                          measure_errors=measure_errors,chisq=chisq)           

           ;Linear fit to find width, since spiky
           l1=linfit(countsum[22:24],gauss[22:24],CHISQR=chisqr, COVAR=covar, $
                     PROB=prob, SIGMA=sigma, measure_errors=measure, $
                     YFIT=yfit)
           l2=linfit(countsum[24:26],gauss[24:26],CHISQR=chisqr, COVAR=covar, $
                     PROB=prob, SIGMA=sigma, measure_errors=measure, $
                     YFIT=yfit)
           x1=findgen(60,start=500)
           y1=l1[0]+x1*l1[1]
           x2=findgen(60,start=540)
           y2=l2[0]+x2*l2[1]
           
           ;actual width finding
           h_peak=gauss[24]-gauss[22]
           loc1=where((y1 ge floor(0.5*h_peak+gauss[22])) AND $
                      (y1 le round(0.5*h_peak+gauss[22])))
           loc2=where((y2 ge floor(0.5*h_peak+gauss[22])) AND $
                      (y1 le round(0.5*h_peak+gauss[22])))
           w_half=x2[loc2[0]]-x1[loc1[0]]
           STOP
           p1=plot(countsum, gauss, /overplot, 'r')
           p2=plot([x1[loc1[0]],x2[loc2[-1]]],[y1[loc1[0]],y2[loc2[-1]]],$
                   /overplot,'b')
           t=text(200,15,/DATA,'Gaussian fit with NTERMS=6', font_size=8.5, 'r')
           t2=text(200,10,/DATA,'Peak Half Width = '+$
                   strcompress(string(w_half),/remove_all), font_size=8.5, 'r')
        end
        
        'q': i=1
        else: print, 'Invalid input.'

     endcase
  endwhile
  print, "Returning to kernel..."
end
