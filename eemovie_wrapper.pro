restore, 'ee_obs_paths.sav'
  for i = 20,n_elements(ee_obs_path)-1 do begin
     print,i
     
     ee_dir = ee_obs_path[i]
     ee_gunzip, ee_dir, data_path
   
   
     eemovie, eepath = [data_path,ee_dir] ,/ffmpeg,/quiet
     STOP
     ee_dataclear,ee_dir

  end

end
