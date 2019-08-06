;*******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

;______ From Mark Decker's code ______
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 5000000000 ;
end setvalues
;_____________________________________

begin

;_______________________________ Pre-define ________________________________

file_name = (/\
               "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_GADY-CABLE_orig_mask.nc",\
               "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_MD_elev_orig_mask.nc",\
               "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_GADY-CABLE_orig_std_mask.nc",\
               "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_MD_elev_orig_std_mask.nc"\
            /)


nml_2D = (/\
              "iveg","isoil","soil_color","landsea",\ ;2D
              "sand","sand2","silt","silt2","clay","clay2","organic","organic2",\
              "hyds","bch","sfc","ssat","sucs","swilt","css","cnsd",\
              "rhosoil","Albedo","albedo2","drainage_density","drainage_dist",\
              "slope","slope_std","Sy","dtb","elevation","elevation_std",\
              "permeability","permeability_std"\
          /)
nml_3D = (/\
              "patchfrac","LAI","SnowDepth",\ ;3D
              "bch_vec","sucs_vec","ssat_vec","swilt_vec","sfc_vec","css_vec","hyds_vec",\
              "rhosoil_vec","cnsd_vec","sand_vec","clay_vec","silt_vec","org_vec","watr"\
             /)
nml_4D = (/"SoilMoist","SoilTemp"/)         ; 4D

;              "time","x","y","rad_dummy","patch","rad","soil",\;1D
;              "soil_depth","longitude","latitude",\


; ______________________________ Forming nc data ____________________________
fcp = addfile (file_name(0),"r")

do var_num = 0, 32
   print(nml_2D(var_num)+" "+num(ismissing(fcp->$nml_2D(var_num)$)))
end do

print(nml_3D(0)+" "+num(ismissing(fcp->$nml_3D(0)$(0,:,:))))

do time = 0,11
   print(nml_3D(1)+" time "+time+" "+num(ismissing(fcp->$nml_3D(1)$(time,:,:))))
end do

do var_num = 2, 16
  do layer = 0,5
     print(nml_3D(var_num)+" layer "+layer+" "+num(ismissing(fcp->$nml_3D(var_num)$(layer,:,:))))
  end do
end do

do var_num = 0,1
  do time = 0,11
    do layer = 0,5
       print(nml_4D(var_num)+" time "+time+" layer "+layer+" "+num(ismissing(fcp->$nml_4D(var_num)$(time,layer,:,:))))
    end do
  end do
end do

end
