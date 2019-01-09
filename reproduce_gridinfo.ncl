;*******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

;______ From Mark Decker's code _____
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 5000000000 ;
end setvalues
;____________________________________

begin

file_name = (/\
         "/srv/ccrc/data03/z3362708/Harmonized_Global_Soil_Data/data",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5_site.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/gridinfo_CSIRO_1x1.nc"\
           /)

var_name1= (/\
             "T_SAND","S_SAND","T_CLAY","S_CLAY","T_SILT","S_SILT","T_OC","S_OC"\
           /)

var_name2= (/\
             "sand","sand2","clay","clay2","silt","silt2","organic","organic2"\
            /)

; __________________________ Forming nc data ____________________________
fcp = addfile (file_name(1),"r")
filo = "gridinfo_mmy.nc"
system("/bin/rm -f " + filo)    ; remove if exists
fout  = addfile (filo, "c")     ; open output file

; explicitly declare file definition mode. Improve efficiency.
setfileoption(fout,"DefineMode",True)

; create global attributes of the file
fAtt               = True            ; assign file attributes
fAtt@title         = "NCL Efficient Approach to netCDF Creation"
fAtt@source_file   =  "original-file.nc"
fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( fout, fAtt )            ; copy file attributes

; predefine the coordinate variables and their dimensionality
; Note: to get an UNLIMITED record dimension, we set the dimensionality
; to -1 (or the actual size) and set the dimension name to True.

nlat  = 360 ;
nlon = 720
ntime = 12 ;
nsoil = 6 ;
npatch = 1 ;
nrad  = 3 ;

dimNames = (/"time", "latitude", "longitude", "soil", "patch", "rad"/)
dimSizes = (/ 12   ,  nlat     ,  nlon      , nsoil , npatch , nrad /)
dimUnlim = (/ False,  False    ,  False     , False , False  , False/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

; predefine the the dimensionality of the variables to be written out
filevardef(fout, "longitude" ,typeof(fcp->longitude),getvardims(fcp->longitude))
filevardef(fout, "latitude" ,typeof(fcp->latitude),getvardims(fcp->latitude))
filevardef(fout, "time" ,typeof(fcp->time),getvardims(fcp->time))

filevardef(fout, "sand"  ,typeof(fcp->sand),getvardims(fcp->sand))
filevardef(fout, "sand2"  ,typeof(fcp->sand2),getvardims(fcp->sand2))
filevardef(fout, "silt"  ,typeof(fcp->silt),getvardims(fcp->silt))
filevardef(fout, "silt2"  ,typeof(fcp->silt2),getvardims(fcp->silt2))
filevardef(fout, "clay"  ,typeof(fcp->clay),getvardims(fcp->clay))
filevardef(fout, "clay2"  ,typeof(fcp->clay2),getvardims(fcp->clay2))
filevardef(fout, "organic"  ,typeof(fcp->organic),getvardims(fcp->organic))
filevardef(fout, "organic2"  ,typeof(fcp->organic2),getvardims(fcp->organic))

filevardef(fout, "bch"  ,typeof(fcp->bch),getvardims(fcp->bch))
filevardef(fout, "sfc"  ,typeof(fcp->sfc),getvardims(fcp->sfc))
filevardef(fout, "ssat"  ,typeof(fcp->ssat),getvardims(fcp->ssat))
filevardef(fout, "sucs"  ,typeof(fcp->sucs),getvardims(fcp->sucs))
filevardef(fout, "swilt"  ,typeof(fcp->swilt),getvardims(fcp->swilt))

; Copy attributes associated with each variable to the file
; All attributes associated with each variable will be copied.
filevarattdef(fout,"longitude",fcp->longitude)
filevarattdef(fout,"latitude",fcp->latitude)
filevarattdef(fout,"time",fcp->time)

filevarattdef(fout,"sand",fcp->sand)
filevarattdef(fout,"sand2",fcp->sand2)
filevarattdef(fout,"clay",fcp->clay)
filevarattdef(fout,"clay2",fcp->clay2)
filevarattdef(fout,"silt",fcp->silt)
filevarattdef(fout,"silt2",fcp->silt2)
filevarattdef(fout,"organic",fcp->organic)
filevarattdef(fout,"organic2",fcp->organic2)

filevarattdef(fout,"bch",fcp->bch)
filevarattdef(fout,"sfc",fcp->sfc)
filevarattdef(fout,"ssat",fcp->ssat)
filevarattdef(fout,"sucs",fcp->sucs)
filevarattdef(fout,"swilt",fcp->swilt)

; explicitly exit file definition mode. **NOT REQUIRED**
setfileoption(fout,"DefineMode",False)

; output only the data values since the dimensionality and such have
; been predefined. The "(/", "/)" syntax tells NCL to only output the
; data values to the predefined locations on the file.

fout->longitude = fcp->longitude
fout->latitude  = fcp->latitude
fout->time      = fcp->time
delete(fcp)

; __________________________ Check Value____________________________
pic = "check_value"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True

; __________________________ Data input ____________________________
sand = new((/360,720/),float)
clay = new((/360,720/),float)
silt = new((/360,720/),float)
sand = 0.
clay = 0.
silt = 0.

f2 = addfile(file_name(1),"r")
Lat = f2->latitude
Lon = f2->longitude

do var_num = 0,5;7

var1 = new((/3600,7200/),float)

f1 = addfile(file_name(0)+"/"+var_name1(var_num)+".nc4","r")

var1 = dble2flt(f1->$var_name1(var_num)$(::-1,:))*1.0
var1@_FillValue = dble2flt(f1->$var_name1(var_num)$@_FillValue) ;7

plot = gsn_csm_contour(wks,var1,res)

var1!0 = "lat"
var1!1 = "lon"
lat = dble2flt(f1->lat(::-1))
lon = dble2flt(f1->lon)
var1&lat = lat
var1&lon = lon

printVarSummary(var1)

var3 = linint2_Wrap(lon,lat,var1,True,Lon,Lat,0)
print(var3)
;var3@_FillValue = var1@_FillValue
plot = gsn_csm_contour(wks,var1,res)
delete(var1(243,324))

sand@_FillValue = var3@_FillValue
clay@_FillValue = var3@_FillValue
silt@_FillValue = var3@_FillValue

if var_num .le. 1 then
   sand = sand + var3
else if var_num .le. 3 then
   clay = clay + var3
else
   silt = silt + var3
end if
end if

fout->$var_name2(var_num)$ = var3

delete(var3)
end do

sand = sand/2./100.
clay = clay/2./100.
silt = silt/2./100.
plot = gsn_csm_contour(wks,sand,res)
plot = gsn_csm_contour(wks,clay,res)
plot = gsn_csm_contour(wks,silt,res)

printVarSummary(sand)
printVarSummary(clay)
printVarSummary(silt)

print("finishing input")

; __________________________ CALCULATION ____________________________
bch   = new((/360,720/),float)
sucs  = new((/360,720/),float)
ssat  = new((/360,720/),float)
swilt = new((/360,720/),float)
sfc   = new((/360,720/),float)
print("finishing allocation")

bch@_FillValue   = -9999.
sucs@_FillValue  = -9999.
ssat@_FillValue  = -9999.
swilt@_FillValue = -9999.
sfc@_FillValue   = -9999.

print("finishing setting missing value")

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

print("finishing adding coordinate")

; soil suction of 3.364m and 152.9m, or equivalent of -0.033 & -1.5 MPa
pressure_head_wilt = -152.9
pressure_head_crit = -3.364
CM_2_M             = 0.01

; Clapp Hornberger exponent [-]
bch = 3.1 + 15.7 * clay - 0.3 * sand
printVarSummary(bch)
plot = gsn_csm_contour(wks,bch,res)

; psi_sat : soil matric potential at saturation, taking inverse of log (base10); units = m
; sucs    : suction at saturation
sucs = CM_2_M * (10.0^(1.54 - 0.95 * sand + 0.63 * silt))*(-1.0)
printVarSummary(sucs)
plot = gsn_csm_contour(wks,sucs,res)

; METER_OF_HEAD_TO_MPA = 9.81 * 0.001
; Height (m) x gravity (m/s2) = pressure (kPa)
;psi_sat_mpa = psi_sat * METER_OF_HEAD_TO_MPA;

; theta_sp: volumetric soil moisture concentrations at the saturation point
; ssat : vol H2O @ saturation
ssat = 0.505 - 0.037 * clay - 0.142 * sand
printVarSummary(ssat)
plot = gsn_csm_contour(wks,ssat,res)

; swilt: vol H2O @ wilting
; theta_wp: volumetric soil moisture concentrations at the wilting point
;          assumed to equal suction of -1.5 MPa or a depth of water of 152.9 m
swilt = ssat * (sucs / pressure_head_wilt)^(1.0 / bch)
printVarSummary(swilt)
plot = gsn_csm_contour(wks,swilt,res)

; sfc : vol H2O @ field capacity
; theta_fc: volumetric soil moisture concentrations at field capacity assumed to
;           equal a suction of -0.0033 MPa or a depth of water of 3.364 m
sfc = ssat * (sucs / pressure_head_crit)^(1.0 / bch)
printVarSummary(sfc)
plot = gsn_csm_contour(wks,sfc,res)

delete(sand)
delete(clay)
delete(silt)
print("finishing calculation")

fout->bch    = bch*1.0
fout->sfc    = sfc*1.0
fout->ssat   = ssat*1.0
fout->sucs   = sucs*1.0
fout->swilt  = swilt*1.0
;delete(fout)

end
