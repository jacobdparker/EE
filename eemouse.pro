;Reform mouseread structure into ee structure. This routine is called 
;via the widget_control kill_notify mechanism when the select_boxes 
;interface is exited.


pro ee_structify, foo 
   ;foo is a dummy argument required by kill_notify mechanism.
common widget_environment, img, didx, tidx, mouseread
common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map, goodmap

rectify_mouseread ;Invoke this subroutine of saj_select_boxes to ensure x0<x1, y0<y1.

if (mouseread.count gt 0) then begin
   ee = replicate({t:0L, y:0L, t0:0L, t1:0L, y0:0L, y1:0L, comment:''}, mouseread.count)
   ee.t0 = mouseread.x0[0:mouseread.count-1]
   ee.t1 = mouseread.x1[0:mouseread.count-1]
   ee.y0 = mouseread.y0[0:mouseread.count-1]
   ee.y1 = mouseread.y1[0:mouseread.count-1]
endif


save, /variables, /comm, file = rasterdir+'ee.sav' 
   ;Note that all the variables & both common blocks are saved, because we 
   ;might need them to /resume later.
foo=dialog_message('saved '+rasterdir+'ee.sav', /information)
end


pro ee_resume,startdir=startdir

common widget_environment, img, didx, tidx, mouseread
common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map, goodmap

;Load an ee.sav file.
eefile = dialog_pickfile(title='Select ee.sav file', path = startdir, get_path=new_rasterdir) 
   ;rasterdir gets redefine here.
restore, eefile

;See if the directory has changed since last time.
if new_rasterdir ne rasterdir then begin
   rasterdir = new_rasterdir
   dialog_message,"Don't Panic. Apparently the directory name has changed since ee.sav was last saved. Please identify the corresponding raster and sji files. They must live in the same directory as ee.sav.",/information
   message,'Looks like the directory name has changed since ee.sav was saved!',/informational   
   rasterfile = dialog_pickfile(title='Select L2 Raster File', path=rasterdir)
   sjifile = dialog_pickfile(title='Select L2 SJI File', path=rasterdir)
endif

;Call saj_select_boxes   
saj_select_boxes, SiIV_EE_map>70<2000  ;?? Arbitrary thresholding here ??
didx_save_for_later = didx
tidx_save_for_later = tidx
restore, eefile ;Restore again to recover contents of widget_environment CB!
didx = didx_save_for_later ;Don't replace didx from eefile, that would be a mistake!
tidx = tidx_save_for_later ;Don't replace tidx from eefile, that would be a mistake!
widget_control, didx.base, kill_notify='ee_structify'
   ;When select_boxes quits, didx.base will be destroyed, and the result
   ;will be a call to ee_structify.

;The following two procedures from saj_select_boxes are used to refresh 
;the table and image displays.
show_image
rectify_mouseread

end


;+
;NAME:
;  EEMOUSE
;PURPOSE:
;  Choose an L2 dataset (we assume that each L2 dataset consists of
;  an IRIS raster file and an SJI file, both fits format), and then 
;  interactively select explosive events from a map that highlights
;  explosive event activity as a function of time (on the horizontal axis)
;  and slit position (on the vertical axis). On exit, and ee structure is
;  saved in the directory that contained the data files, as ee.sav.
;  Note that it is not necessary to click "SAVE" from the saj_select_boxes
;  widget. It is also possible to save your work and resume later, using
;  the /resume option.
;CALLING SEQUENCE:
;  eemouse [, /resume]
;OPTIONAL INPUT KEYWORDS:
;  resume = if set, then load an existing ee.sav file from a previous session,
;     and continue to browse the EE map and/or edit the EE data structure.
;  preprocess = if set, just do the EE map generation and exit, saving ee.sav.
;     No widgets will come up. Use /resume to fill out the EE table.
;DEPENDENCIES:
;  despik
;  saj_select_boxes
;  fuv_bg_model
;  prank
;MODIFICATION HISTORY:
;  2014-May C. Kankelborg
;  2014-Jun-16 CCK fixed bug where changing directory name enclosing ee.sav
;     caused problems. Now rasterdir is redefined every time ee.sav is loaded
;     using the /resume option, based on where ee.sav was actually found.
;     The user is prompted to re-identify rasterfile and sjifile.
;  2017-May-17 JDP modified to store ee.sav in the rasterdir and takes an input
;     directory and filename
pro eemouse, resume=resume, preprocess=preprocess, startdir=startdir, wrapper_state=wrapper_state, where_box=where_box

;logo = read_png('mouse.png')
;logosize=size(logo)
;nxlogo = logosize[2]
;nylogo = logosize[3]
;window, 13, xsize=nxlogo, ysize=nylogo, title="Explosive Mouse Events!"
;tv, logo, /true

;Select and load dataset.
if keyword_set(resume) then begin
   ee_resume,startdir=startdir ;Separate routine eliminates collision of common blocks, i hope...
   return
endif
common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map, goodmap
;Load a new L2 data set.

if keyword_set(startdir) then begin
   rasterdir = startdir
   rasterfile = dialog_pickfile(title='Select L2 Raster File', path=rasterdir)
endif else begin
   rasterfile = dialog_pickfile(title='Select L2 Raster File', get_path=rasterdir)
endelse
read_iris_l2, rasterfile, SiIV_index, SiIV_data, wave = 'Si IV'
;ee_fits_save, siiv_index[0], wrapper_state, rasterdir

sjifile = dialog_pickfile(title='Select L2 SJI File', path=rasterdir)


;Data reduction
message,'Despiking...', /informational
SiIV_data = despik(temporary(SiIV_data),  sigmas=4.0, Niter=20, min_std=4.0,goodmap=goodmap) ;DESPIKE.
message,'Removing instrumental background...', /informational
dark_model = fuv_bg_model(SiIV_data, percentile=35, /replace) ;background subtraction

;Create EE SiIV_EE_map
lambda = SiIV_index[0].wavemin + SiIV_index[0].cdelt1*findgen(SiIV_index[0].naxis1)
   ;wavelength axis, Angstroms
lambda0 = SiIV_index.wavelnth  ;central wavelength for Si IV.
c = 3e5 ;speed of light, km/s
velocity = c * (lambda - lambda0)/lambda0 ;velocity axis, km/s
explosive_threshold = 60.0 ;km/s. SiIV has T=10^4.8, c_s = 40 km/s.
explosive_velocities = abs(velocity) gt explosive_threshold ;mask in wavelength space
SiIV_Nt = (size(SiIV_data))[3]
SiIV_Ny = (size(SiIV_data))[2]
SiIV_EE_map = fltarr(SiIV_Nt, SiIV_Ny)
for i=0, SiIV_Nt-1 do begin ;cycle through FUV SG exposures.
   ;Evaluate a measure of explosive event activity for this timestep
   SiIV_EE_map[i,*] = total( (explosive_velocities # replicate(1.0,SiIV_Ny)) * SiIV_data[*,*,i], 1)
endfor

if keyword_set(preprocess) then begin ;end here with no widget work.
   message,'saving '+rasterdir+'ee.sav', /informational
   save, rasterfile, rasterdir, sjifile, SiIV_EE_map, file=rasterdir+'ee_15.sav'
   return 
endif

;Call saj_select_boxes

restore, where_box

common widget_environment, img, didx, tidx, mouseread 
   ;make results of saj_select_boxes available in this scope.
saj_select_boxes, SiIV_EE_map>70<2000                         ;?? Arbitrary thresholding here ??
widget_control, didx.base, kill_notify='ee_structify'
   ;When select_boxes quits, didx.base will be destroyed, and the result
   ;will be a call to ee_structify.
 

end
