;FUNCTION: ee_box_data
;PURPOSE: Make and return array of x0, x1, y0, y1 values for each box in each
;observation
;PARAMETERS:
;  files=all filepaths to ee.sav files containing box data
;VARIABLES:
;  arr=array that contains data of x0, x1, y0, y1
;  vals=temporary array containing box values for each observation
;RETURNS: arr
;AUTHOR(S): A.E. Bartz & J.D. Parker 6/8/17
function ee_box_data, files

  arr=fltarr(100,4,n_elements(files))
  
  ;Restore files one by one and fill in array with values
  for i=0,n_elements(files)-1 do begin
     restore, files[i]
     vals=[[mouseread.x0], [mouseread.x1], [mouseread.y0], [mouseread.y1]]
     arr[0,0,i]=vals
  endfor
     
  return, arr
end

;FUNCTION: ee_event_counts
;PURPOSE: Make and return array containing the total number of boxes drawn
;for all EE observations
;PARAMETERS:
;  files=all filepaths to ee.sav files containing box data
;VARIABLES:
;  n=length of files array
;  counts=integer array containing number of boxes drawn per array
;RETURNS: counts
;AUTHOR(S): A.E. Bartz, 6/9/17
function ee_event_counts, files

  ;Restore files
  n=n_elements(files)
  counts=make_array(n)

  ;Fill array
  for i=0,n-1 do begin
     restore, files[i]
     counts[i]=mouseread.count
  endfor

  return, counts
end

;FUNCTION: ee_pathdates
;PURPOSE: Compute dates of observations from the EE filepath array
;PARAMETERS: files=all filepaths to ee.sav data
;VARIABLES:
;  dates=array of Julian dates for each observation
;  current=string in format "yearmonthday_hourminsec" with 15 characters
;  year, month, day, hour, minute = integers
;RETURNS: array of Julian dates
;AUTHOR(S): A.E. Bartz 6/9/17
function ee_pathdates, files

  n=n_elements(files)
  dates=fltarr(n)
  
  ;Write the dates into array
  for i=0,n-1 do begin
     current=files[i]
     year=strmid(current,11,4)
     month=strmid(current,16,2)
     day=strmid(current,19,2)
     hour=strmid(current,25,2)
     minute=strmid(current,27,2)
     dates[i]=GREG2JUL(month,day,year,hour,minute)
  endfor

  return, dates
end  
  
