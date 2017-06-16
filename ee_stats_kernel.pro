;KERNEL
;PURPOSE: Perform variety of statistical functions on EE data  based
;on user input
;VARIABLES:
;  files=array of filepaths of ee.sav files
;  arr=array of x0,x1,y0,y1 data for each of ee.sav files
;  counts=array of number of boxes drawn in each ee.sav file
;  dates=array of julian dates of each ee.sav observation
;  i,j=counting variables
;  input,char=character input read from terminal
;FIND DESCRIPTIONS OF OUTSOURCED FUNCTIONS/PROCEDURES IN THEIR INDIVIDUAL FILES
;AUTHOR(S): A.E.Bartz 6/9/17

print, "This program performs statistical analyses on IRIS sit and stare data."

varfile=file_search('variables.sav')
if varfile ne '' then begin
   restore, varfile
   varfile=!NULL                ;free memory
   print, "Data restored."
endif else begin
   print, "Initializing data..."
   files=file_search("../EE_Data","ee_*.sav")
   print, 'Finding event dates...'
   dates=ee_pathdates(files)
   print, 'Assigning data boxes...'
   arr=ee_box_data(files)
   print, 'Assigning event counts...'
   counts=ee_event_counts(files)
endelse
files=!NULL                     ;free memory

i=0
j=0
while i eq 0 do begin
   print, format='(%"\nType one of the letters below to perform its corresponding analysis.")'
   print, format='(%"t - time statistics\ny - position statistics\nc - overall statistics\ns - scatter plots\nw - gimme a second\nq - quit the program")'
   input=''
   wait, 1
   READ, input, PROMPT='Type an option here: '

   case input of
      't': begin
         ee_timestats, arr, dates, counts
         wait, 1
         STOP, "Type .c when you're done with the data."
         break
      end

      'y': begin
         ee_ystats, arr, dates, counts
         wait, 1
         STOP, "Type .c when you're done with the data."
      end

      'c': begin
         ee_overallstats, arr, dates, counts
         wait, 1
         STOP, "Type .c when you're done with the data."
      end
      
      'q': begin
         print, "Exiting the program..."
         i=1
         j=1
         break
      end

      's': begin
         ee_scatter, arr, dates, counts
         j=1
         break
      end

      'w': begin
         STOP, "Ok, giving you a second! Type .c to continue when you're ready."
         j=1
      end
      
      else: begin
         print, "Invalid input."
         wait, 2
      endelse
      
   endcase

       while j eq 0 do begin
          char=''
          read, char, PROMPT='Continue program? (y/n) '
          if (char eq 'y') or (char eq 'yes') then begin
             wait, 1
             break
          endif
          if (char eq 'n') or (char eq 'no') then begin
             print, "Exiting..."
             i=1
             wait, 2
             break
          endif else begin
             print, "Invalid input."
             wait, 1
             continue
          endelse
       endwhile
           
    endwhile

end
