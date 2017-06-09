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
;RETURNS:
;SAVES:
;AUTHOR(S): A.E.Bartz 6/9/17

functions=['ee_data_search','ee_timestats']
RESOLVE_ROUTINE, functions, /COMPILE_FULL_FILE

print, "Initializing data..."
files=file_search("../EE_Data","ee*.sav")
arr=ee_box_data(files)
counts=ee_event_counts(files)
dates=ee_pathdates

i=0
while i eq 0 do begin
   print, format='(%"\nThis program performs statistical analyses on selected IRIS slitjaw data. Type one of the letters below to perform its corresponding analysis.")'
   print, format='(%"t - time statistics\ny - position statistics\nc - overall statistics\nq - quit the program")'
   input=''
   wait, 1
   READ, input, PROMPT='Type an option here: '

   case input of
      't': begin
         print, "Here is where time stuff will go when I know how this works."
         wait, 1
         break
      end

      'y': begin
         print, "Position statistics not yet implemented."
         wait, 1
         j=0
         while j eq 0 do begin
            char=''
            read, char, PROMPT='Continue program? (y/n) '
            if (char eq 'y') or (char eq 'yes') then begin
               wait, 1
               break
               endif
            if (char eq 'n') or (char eq 'no') then begin
               print, "Exiting..."
               wait, 2
               i=1
               break
            endif else begin
               print, "Invalid input."
               wait, 1
               continue
            endelse
         endwhile   
      end

      'c': begin
         print, "Overall statistics not yet implemented."
         wait, 1
         j=0
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
      end

      'q': begin
         print, "Exiting the program..."
         wait, 2
         i=1
         break
      end

      else: begin
         print, "Invalid input, returning..."
         wait, 2
      endelse
      
   endcase

endwhile

end
