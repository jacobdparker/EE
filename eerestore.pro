pro eerestore

  common widget_environment, img, didx, tidx, mouseread
  common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map
  common data, rasterindex,rasterdata,sjiindex,sjidata



  
  ;Load an ee.sav file.
  eefile = dialog_pickfile(title='Select ee.sav file', get_path=new_rasterdir) 
  ;rasterdir gets redefine here.
  restore, eefile


  ;See if the directory has changed since last time.
  if new_rasterdir ne rasterdir then begin
     rasterdir = new_rasterdir

     foo = dialog_message("Don't Panic. Apparently the directory name has changed since ee.sav was last saved. Please identify the corresponding raster and sji files. They must live in the same directory as ee.sav.",/information)

     rasterfile = dialog_pickfile(title='Select L2 Raster File', path=rasterdir)
     sjifile = dialog_pickfile(title='Select L2 SJI File', path=rasterdir)
  endif


  message,'Reading SJI data...',/information
  read_iris_l2, sjifile, sjiindex, sjidata
  sjidata[where(sjidata eq -200)]=!values.f_nan

  message,'Reading raster data...',/information
  read_iris_l2, rasterfile, rasterindex, rasterdata, WAVE= 'Si IV'
  rasterdata[where(rasterdata eq -200)]=!values.f_nan

  message,'Subtracting raster background...',/information
  dark_model = fuv_bg_model(rasterdata, percentile=35, $
                            bad_data=!values.f_nan) ;background subtraction

end
