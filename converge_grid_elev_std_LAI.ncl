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

file_name = (/\
         "/srv/ccrc/data03/z3362708/Harmonized_Global_Soil_Data/data",\ ; lat from - to + lon from -180 to 180
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5_site.nc",\ ;lat from + to - lon from -180 to 180
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/GSWP3_gwmodel_parameters.nc",\ ;lat from - to + lon from 0 to 360
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/gridinfo_CSIRO_1x1.nc"\ ;lat from + to - lon from -180 to 180
           /)
; /srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/gridinfo_CSIRO_1x1.nc ;lat from + to - lon from -180 to 180
var_name1= (/\
             "T_SAND","S_SAND","T_CLAY","S_CLAY","T_SILT","S_SILT","T_OC","S_OC"\
           /)

var_name2= (/\
             "sand","sand2","clay","clay2","silt","silt2","organic","organic2"\
            /)

gridinfo_nml = (/\
              "time","longitude","latitude",\
              "x","y","rad_dummy","patch","rad","soil",\
              "iveg","isoil","patchfrac","soil_color","landsea",\
              "sand","sand2","silt","silt2","clay","clay2","organic","organic2",\
              "hyds","bch","sfc","ssat","sucs","swilt","css",\
              "cnsd","rhosoil","LAI","Albedo","albedo2",\
              "SnowDepth","SoilMoist","SoilTemp"\
              /)


cp_gridinfo = (/\
                "time","x","y","rad_dummy","patch","rad","soil",\
                "latitude","longitude","patchfrac",\
                "iveg","isoil","soil_color","landsea","cnsd","rhosoil",\
                "Albedo","albedo2",\ ; "LAI",
                "SnowDepth","SoilMoist","SoilTemp"\
                /)

elev_nml = (/\
              "soil_depth",\
              "drainage_density","drainage_dist",\
              "slope","slope_std",\
              "Sy","dtb","elevation","elevation_std",\
              "permeability","permeability_std",\
              "bch_vec","sucs_vec","ssat_vec","swilt_vec","sfc_vec","css_vec","hyds_vec",\
              "rhosoil_vec","cnsd_vec",\
              "sand_vec","clay_vec","silt_vec","org_vec",\ ; top 3 ->sand/clay/silt lower 3 ->sand2/clay2/silt2
              "watr"\
           /)
           ; "latitude","longitude",

cp_elev = (/\
             "soil_depth",\
             "Sy","drainage_density","drainage_dist",\
             "slope","slope_std",\
             "dtb","elevation","elevation_std",\
             "permeability","permeability_std",\
             "watr"\
            /)
            ; "bch_vec","sucs_vec","ssat_vec","swilt_vec","sfc_vec","css_vec","hyds_vec",\
            ; "rhosoil_vec","cnsd_vec",\
            ; "sand_vec","clay_vec","silt_vec","org_vec",\ ; top 3 ->sand/clay/silt lower 3 ->sand2/clay2/silt2



; __________________________ Forming nc data ____________________________
fcp = addfile (file_name(1),"r")
fcp2 = addfile(file_name(2),"r")

filo = "gridinfo_mmy.nc"
system("/bin/rm -f " + filo)    ; remove if exists
fout  = addfile (filo, "c")     ; open output file

; explicitly declare file definition mode. Improve efficiency.
setfileoption(fout,"DefineMode",True)

; create global attributes of the file
fAtt               = True            ; assign file attributes
fAtt@title         = "converge gridinfo and elev"
fAtt@source_file   = "CABLE_UNSW_GSWP3_gridinfo_0.5x0.5_site.nc and GSWP3_gwmodel_parameters.nc"
fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( fout, fAtt )            ; copy file attributes

; predefine the coordinate variables and their dimensionality
; Note: to get an UNLIMITED record dimension, we set the dimensionality
; to -1 (or the actual size) and set the dimension name to True.

nlat   = 360 ;
nlon   = 720
ntime  = 12 ;
nsoil  = 6 ;
npatch = 1 ;
nrad   = 3 ;
nsdepth = 6

dimNames = (/"time", "latitude", "longitude", "soil", "patch", "rad", "soil_depth"/)
dimSizes = (/ 12   ,  nlat     ,  nlon      , nsoil , npatch , nrad , nsdepth     /)
dimUnlim = (/ False,  False    ,  False     , False , False  , False, False       /)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

; predefine the the dimensionality of the variables to be written out
do var_num = 0,36
  print("Predefine " + gridinfo_nml(var_num))
  filevardef(fout, gridinfo_nml(var_num),typeof(fcp->$gridinfo_nml(var_num)$),getvardims(fcp->$gridinfo_nml(var_num)$))
end do
do var_num = 0,24
  print("Predefine " + elev_nml(var_num))
;  if var_num .eq. 0 then
  filevardef(fout, elev_nml(var_num),typeof(fcp2->$elev_nml(var_num)$), getvardims(fcp2->$elev_nml(var_num)$))
;  else if var_num .lt. 10 then
;     ;filevardef(fout, elev_nml(var_num),"float", (/"latitude", "longitude"/))
;     fout->$elev_nml(var_num)$!0  = "latitude"
;     fout->$elev_nml(var_num)$!1  = "longitude"
;     fout->$elev_nml(var_num)$&latitude  = fcp->latitude
;     fout->$elev_nml(var_num)$&longitude = fcp->longitude
;  else
;     ;filevardef(fout, elev_nml(var_num),"float", (/"soil_depth", "latitude", "longitude"/))
;     fout->$elev_nml(var_num)$!0  = "soil_depth"
;     fout->$elev_nml(var_num)$!1  = "latitude"
;     fout->$elev_nml(var_num)$!2  = "longitude"
;     fout->$elev_nml(var_num)$&soil_depth= fcp->soil_depth
;     fout->$elev_nml(var_num)$&latitude  = fcp->latitude
;     fout->$elev_nml(var_num)$&longitude = fcp->longitude
;  end if
;  end if
end do

; Copy attributes associated with each variable to the file
; All attributes associated with each variable will be copied.
do var_num = 0,36
  print("Copy attributes " + gridinfo_nml(var_num))
  filevarattdef(fout,gridinfo_nml(var_num),fcp->$gridinfo_nml(var_num)$)
;  if var_num .ge. 7 then
;     fout->$gridinfo_nml(var_num)$&latitude  = fcp2->latitude
;     fout->$gridinfo_nml(var_num)$&longitude = fcp2->longitude
;  end if
end do
;fout->x&longitude = fcp2->longitude
;fout->y&latitude  = fcp2->latitude

do var_num = 0,24
  print("Copy attributes " + elev_nml(var_num))
  filevarattdef(fout,elev_nml(var_num),fcp2->$elev_nml(var_num)$)
end do

; explicitly exit file definition mode. **NOT REQUIRED**
setfileoption(fout,"DefineMode",False)
print("Exit DefineMode")

; output only the data values since the dimensionality and such have
; been predefined. The "(/", "/)" syntax tells NCL to only output the
; data values to the predefined locations on the file.

do var_num = 0,20
   print("Copy gridinfo "+cp_gridinfo(var_num))
   fout->$cp_gridinfo(var_num)$ = fcp->$cp_gridinfo(var_num)$*1
;end do
;do var_num = 6,14
;   print("Copy gridinfo "+cp_gridinfo(var_num))
;   fout->$cp_gridinfo(var_num)$ = fcp->$cp_gridinfo(var_num)$(::-1,:)*1.0
end do
;fout->y         = fcp->y(::-1)*1.0
;fout->patchfrac = fcp->patchfrac(:,::-1,:)*1.0
;fout->SnowDepth = fcp->SnowDepth(:,::-1,:)*1.0
;fout->SoilMoist = fcp->SoilMoist(:,:,::-1,:)*1.0
;fout->SoilTemp  = fcp->SoilTemp(:,:,::-1,:)*1.0

do var_num = 0,11
   print("Copy elev "+cp_elev(var_num))
   if var_num .eq. 0 then
      fout->$cp_elev(var_num)$ = fcp2->$cp_elev(var_num)$
   else if var_num .eq. 11 then
      fout->$cp_elev(var_num)$ = lonFlip(fcp2->$cp_elev(var_num)$(:,::-1,:))
   else
      fout->$cp_elev(var_num)$ = lonFlip(fcp2->$cp_elev(var_num)$(::-1,:))
   end if
   end if
end do

delete(fcp)
delete(fcp2)

; __________________________ Check Value____________________________
pic = "check_value"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
res            = True
res@cnFillMode = "RasterFill"            ; Raster Mode
res@cnFillOn   = True
res@cnLinesOn  = False

; __________________________ Data input ____________________________
sand = new((/360,720/),float)
clay = new((/360,720/),float)
silt = new((/360,720/),float)
sand = 0.
clay = 0.
silt = 0.

f2 = addfile(file_name(1),"r")
Lat = f2->latitude(::-1)
Lon = f2->longitude

f4 = addfile(file_name(3),"r")
Lat_std = fspan(89.5,-89.5,180)
Lon_std = f4->longitude

LAI_std = new((/12,180,360/),float)
LAI_std@_FillValue = f4->LAI@missing_value

LAI_std(:,:149,:) =  f4->LAI*1.0
LAI_std(:,150:,:) =  LAI_std@_FillValue
LAI_std!0 = "time"
LAI_std!1 = "lat"
LAI_std!2 = "lon"
LAI_std&lat = Lat_std
LAI_std&lon = Lon_std

LAI = linint2(Lon_std,Lat_std(::-1),LAI_std(:,::-1,:),True,Lon,Lat,0);_Wrap
; Lat & Lon must be strictly monotonically increasing
fout->LAI = LAI(:,::-1,:)

plot = gsn_csm_contour(wks,fout->LAI(0,:,:)*1.0,res)

print(fout->LAI(0,:,:))
delete(f4)
delete(LAI)
delete(LAI_std)
delete(Lat_std)
delete(Lon_std)

print("finishing LAI input")

do var_num = 0,7

var1 = new((/3600,7200/),float)

f1 = addfile(file_name(0)+"/"+var_name1(var_num)+".nc4","r")
var1 = dble2flt(f1->$var_name1(var_num)$)*1.0/100.;
var1@_FillValue = dble2flt(f1->$var_name1(var_num)$@_FillValue) ;7

plot = gsn_csm_contour(wks,var1,res)

var1!0 = "lat"
var1!1 = "lon"
lat = dble2flt(f1->lat);(::-1)
lon = dble2flt(f1->lon)
var1&lat = lat
var1&lon = lon

printVarSummary(var1)

var3 = linint2_Wrap(lon,lat,var1,True,Lon,Lat,0)
delete(var1)
var3 = var3(::-1,:)
var3!0 = "lat"
var3!1 = "lon"
var3&lat = Lat
var3&lon = Lon

printVarSummary(var3)
;var3@_FillValue = var1@_FillValue
plot = gsn_csm_contour(wks,var3,res)


sand@_FillValue = var3@_FillValue
clay@_FillValue = var3@_FillValue
silt@_FillValue = var3@_FillValue

if var_num .le. 1 then
   sand = sand + var3
else if var_num .le. 3 then
   clay = clay + var3
else if var_num .le. 5 then
   silt = silt + var3
end if
end if
end if

fout->$var_name2(var_num)$ = var3*1.0

delete(var3)
end do

sand = sand/2.
clay = clay/2.
silt = silt/2.
plot = gsn_csm_contour(wks,sand,res)
plot = gsn_csm_contour(wks,clay,res)
plot = gsn_csm_contour(wks,silt,res)

printVarSummary(sand)
printVarSummary(clay)
printVarSummary(silt)

print("finishing input")

; __________________________ CALCULATION ____________________________
hyds  = new((/360,720/),float)
bch   = new((/360,720/),float)
sucs  = new((/360,720/),float)
ssat  = new((/360,720/),float)
swilt = new((/360,720/),float)
sfc   = new((/360,720/),float)
css   = new((/360,720/),float)
print("finishing allocation")

hyds@_FillValue  = -9999.
bch@_FillValue   = -9999.
sucs@_FillValue  = -9999.
ssat@_FillValue  = -9999.
swilt@_FillValue = -9999.
sfc@_FillValue   = -9999.
css@_FillValue   = -9999.

print("finishing setting missing value")

hyds!0 = "lat"
hyds!1 = "lon"
hyds&lat = Lat({::-1})
hyds&lon = Lon

bch!0 = "lat"
bch!1 = "lon"
bch&lat = Lat({::-1})
bch&lon = Lon

sucs!0 = "lat"
sucs!1 = "lon"
sucs&lat = Lat({::-1})
sucs&lon = Lon

ssat!0 = "lat"
ssat!1 = "lon"
ssat&lat = Lat({::-1})
ssat&lon = Lon

swilt!0 = "lat"
swilt!1 = "lon"
swilt&lat = Lat({::-1})
swilt&lon = Lon

sfc!0 = "lat"
sfc!1 = "lon"
sfc&lat = Lat({::-1})
sfc&lon = Lon

css!0 = "lat"
css!1 = "lon"
css&lat = Lat({::-1})
css&lon = Lon

print("finishing adding coordinate")

; soil suction of 3.364m and 152.9m, or equivalent of -0.033 & -1.5 MPa
pressure_head_wilt = -152.9
pressure_head_crit = -3.364
CM_2_M             = 0.01

;From cosby_multivariate of cable_parameters.F90 in CABLE : Marks_latest_branch_with_fixes
hyds = 0.00706*(10.0^(-0.60 + 1.26*sand + (-0.64)*clay)) ;* exp(-soil%hkrz(i)*(soil_depth(i,klev)-soil%zdepth(i)))
; CABLE-2.3.4-GW-Medlyn uses the cosby_univariate equation and does't have this -> * exp(-soil%hkrz(i)*(soil_depth(i,klev)-soil%zdepth(i)))
; Thus, I guess the exp part is only an adjust. I remove it from cosby_multivariate in Marks_latest_branch_with_fixes
plot = gsn_csm_contour(wks,hyds,res)

;______________ From Martin's GDAY/src/water_balance.c ______________

; Clapp Hornberger exponent [-]
bch = 3.1 + 15.7 * clay - 0.3 * sand
; CABLE : soil%bch_vec(i,klev) = 3.1 + 15.4*soil%clay_vec(i,klev) -  0.3*soil%sand_vec(i,klev)
; Careful : 15.7 and 15.4, which is the correct one ?
plot = gsn_csm_contour(wks,bch,res)

; psi_sat : soil matric potential at saturation, taking inverse of log (base10); units = m
; sucs    : suction at saturation
sucs = CM_2_M * (10.0^(1.54 - 0.95 * sand + 0.63 * silt))*(-1.0)
; CABLE: soil%sucs_vec(i,klev) = 10.0 * 10.0**(1.54 - 0.95*soil%sand_vec(i,klev) + 0.63*soil%silt_vec(i,klev) )
; Are their units are different ? Yes, m in gridinfo and mm in CABLE codes
plot = gsn_csm_contour(wks,sucs,res)

; METER_OF_HEAD_TO_MPA = 9.81 * 0.001
; Height (m) x gravity (m/s2) = pressure (kPa)
;psi_sat_mpa = psi_sat * METER_OF_HEAD_TO_MPA;

; theta_sp: volumetric soil moisture concentrations at the saturation point
; ssat : vol H2O @ saturation
ssat = 0.505 - 0.142 * sand - 0.037 * clay
printVarSummary(ssat)
plot = gsn_csm_contour(wks,ssat,res)

; swilt: vol H2O @ wilting
; theta_wp: volumetric soil moisture concentrations at the wilting point
;          assumed to equal suction of -1.5 MPa or a depth of water of 152.9 m
swilt = ssat * (sucs / pressure_head_wilt)^(1.0 / bch)
;CABLE : psi_tmp(i,klev) = abs(psi_c(veg%iveg(i)))
;CABLE : soil%swilt_vec(i,klev) = (ssnow%ssat_hys(i,klev)-ssnow%watr_hys(i,klev)) * &
;                         (psi_tmp(i,klev)/soil%sucs_vec(i,klev))&
;                          **(-1.0/soil%bch_vec(i,klev))+&
;                         ssnow%watr_hys(i,klev)
printVarSummary(swilt)
plot = gsn_csm_contour(wks,swilt,res)

; sfc : vol H2O @ field capacity
; theta_fc: volumetric soil moisture concentrations at field capacity assumed to
;           equal a suction of -0.0033 MPa or a depth of water of 3.364 m
sfc = ssat * (sucs / pressure_head_crit)^(1.0 / bch)
printVarSummary(sfc)
plot = gsn_csm_contour(wks,sfc,res)
; CABLE : soil%sfc_vec(i,klev) = (gw_params%sfc_vec_hk/soil%hyds_vec(i,klev))&
;                        **(1.0/(2.0*soil%bch_vec(i,klev)+3.0)) *&
;                        (ssnow%ssat_hys(i,klev)-ssnow%watr_hys(i,klev)) &
;                        + ssnow%watr_hys(i,klev)
;From soil_thermal_fix of cable_parameters.F90 in CABLE : Marks_latest_branch_with_fixes

; CABLE : soil%cnsd_vec(i,klev) = ( (0.135*(1.0-ssat_bounded(i,klev))) +&
;                    (64.7/soil%rhosoil_vec(i,klev)) ) / &
;                  (1.0 - 0.947*(1.0-ssat_bounded(i,klev)))
; CABLE : soil%rhosoil_vec(i,klev) = soil%rhosoil_vec(i,klev)/(1.0-soil%ssat_vec(i,klev))

;took avg of results from A New Perspective on Soil Thermal Properties Ochsner, Horton,Tucheng Soil Sci Soc America 2001
;!to find what silt (1.0-sand-clay) is !simply regress to his means !in J/kg/K
css = 910.6479*silt + 916.4438 * clay + 740.7491*sand ; CABLE
css = where(css .ge. 800.0, css, 800.0 )
plot = gsn_csm_contour(wks,css,res)

delete(sand)
delete(clay)
delete(silt)
print("finishing calculation")

fout->hyds   = hyds/1000.
fout->bch    = bch*1.0
fout->sfc    = sfc*1.0
fout->ssat   = ssat*1.0
fout->sucs   = sucs*1.0
fout->swilt  = swilt*1.0
fout->css    = css*1.0
;delete(fout)
print("finishing gridinfo output")

do layer = 0,5
fout->hyds_vec(layer,:,:)   = hyds*1.0
fout->bch_vec(layer,:,:)    = bch*1.0
fout->sfc_vec(layer,:,:)    = sfc*1.0
fout->ssat_vec(layer,:,:)   = ssat*1.0
fout->sucs_vec(layer,:,:)   = sucs*1.0
fout->swilt_vec(layer,:,:)  = swilt*1.0
fout->css_vec(layer,:,:)    = css*1.0
fout->rhosoil_vec(layer,:,:)= fout->rhosoil*1.0
fout->cnsd_vec(layer,:,:)   = fout->cnsd*1.0
end do
print("finishing hyds_vec - cnsd_vec output")

do layer = 0,2
fout->sand_vec(layer,:,:)   = fout->sand*1.0
fout->clay_vec(layer,:,:)   = fout->clay*1.0
fout->silt_vec(layer,:,:)   = fout->silt*1.0
fout->org_vec(layer,:,:)    = fout->organic*1.0
end do
do layer = 3,5
fout->sand_vec(layer,:,:)   = fout->sand2*1.0
fout->clay_vec(layer,:,:)   = fout->clay2*1.0
fout->silt_vec(layer,:,:)   = fout->silt2*1.0
fout->org_vec(layer,:,:)    = fout->organic2*1.0
end do

print("finishing soil texture output")

print("finishing elev output")

end
