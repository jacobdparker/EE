restore, 'ee_obs_paths.sav'
  for i = 0,n_elements(ee_obs_path) do begin
     ee_dir = ee_obs_path[i]
     ee_gunzip, ee_dir, data_path
     STOP
     eemovie, eepath = data_path,/mencoder
     STOP
     ee_dataclear,ee_dir
     STOP
  end

end
