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

; _________________________ Check Value ____________________________
pic = "check_map"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
res            = True
res@cnFillMode = "RasterFill"            ; Raster Mode
res@cnFillOn   = True
res@cnLinesOn  = False

; ______________________________ Forming nc data ____________________________
fcp = addfile (file_name(2),"w")

fcp->latitude = fcp->latitude(::-1)
fcp->longitude = fspan(0.25,359.75,720)
print("lat")

do var_num = 0,32
print(var_num)
   fcp->$nml_2D(var_num)$ = lonFlip(fcp->$nml_2D(var_num)$(::-1,:))*1.0
   plot = gsn_csm_contour(wks,fcp->$nml_2D(var_num)$*1.,res)
end do

do var_num = 0,16
print(var_num)
  fcp->$nml_3D(var_num)$ = lonFlip(fcp->$nml_3D(var_num)$(:,::-1,:))*1.0
  plot = gsn_csm_contour(wks,fcp->$nml_3D(var_num)$(0,:,:)*1.,res)
end do

do var_num = 0,1
print(var_num)
  fcp->$nml_4D(var_num)$ = lonFlip(fcp->$nml_4D(var_num)$(:,:,::-1,:))*1.0
  plot = gsn_csm_contour(wks,fcp->$nml_4D(var_num)$(0,0,:,:)*1.,res)
end do


;Lat = f2->latitude(::-1)
;Lon = f2->longitude


end
