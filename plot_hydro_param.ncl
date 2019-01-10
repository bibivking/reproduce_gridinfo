;*******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

;______ From Mark Decker's code _____
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 10000000000 ;1000000000
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

var_name2= (/"bch","sucs","ssat","sfc","swilt","hyds","css",\
             "iveg","isoil",\
             "cnsd","rhosoil","albedo2",\
             "Albedo",\ ;standard 3D Mark 2D
             "SnowDepth","LAI","patchfrac",\ ; 3D
             "SoilMoist","SoilTemp",\ ;4D
             "landsea","soil_color",\ ;NOT in f2
             "sand","sand2","clay","clay2","silt","silt2","organic","organic2"\ 
            /)

; __________________________ PLOT SETTING ____________________________
res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True
res@tmBorderThicknessF = 3.0

;************** ????labelbar ***************
res@lbBoxLinesOn       = True
res@lbTitleFont        = 25
res@lbLabelFont        = 25
res@lbTitleFontHeightF = 0.013
res@lbLabelFontHeightF = 0.013
res@txString           = ""
res@tmXBLabelFont      = 25 ;Sets the font index for the bottom X-Axis labels.
res@tmYLLabelFont      = 25

;***********************************************
res@cnLinesOn          = False
res@cnLineColor        = "black"
res@cnLineThicknessF   = 1.5
res@cnLineLabelsOn     = False
res@gsnMaximize        = True

res@cnExplicitLabelBarLabelsOn = True
res@cnLevelSelectionMode       = "ExplicitLevels"

;***********************************************
res@tmXBLabelFontThicknessF = 0.015
res@tmYLLabelFontThicknessF = 0.015
res@tmXBLabelFontHeightF    = 0.015
res@tmYLLabelFontHeightF    = 0.015

;***********************************************
pres                      = True   ; ???? panel resources.
pres@gsnMaximize          = True
pres@gsnPanelLabelBar     = True   ; ???? panel labelbar.
pres@cnLevelSelectionMode = "ExplicitLevels" ;"ManualLevels"
pres@lbBoxLinesOn         = True   ; ???lbar box ????
pres@lbTitleFont          = 25
pres@lbLabelFont          = 25
pres@lbTitleFontHeightF   = 0.013
pres@lbLabelFontHeightF   = 0.013
pres@lbAutoManage         = False
pres@lbTitleDirection     = "Across"             ; title direction
pres@lbTitlePosition      = "Bottom";Right"

plots = new(3,graphic)

pic = "reproduce_gridinfo"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
res@gsnDraw       = False  ; Don't draw plots;
res@gsnFrame      = False
res@lbLabelBarOn  = True;False
pres@lbLabelBarOn = False;True

f  = addfile("gridinfo_mmy.nc","r")
f2 = addfile(file_name(2),"r")
f3 = addfile(file_name(1),"r")

var1   = f->sfc
var1   = var1 - f->swilt
var2   = f2->sfc
var2   = var2 - f2->swilt
var3   = f3->sfc
var3   = var3 - f3->swilt

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude

var2!0 = "lat"
var2!1 = "lon"
var2&lat = f2->latitude
var2&lon = f2->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

res@cnLevels = fspan(0.,0.22,12)
pres@cnLevels = fspan(0.,0.22,12)
pres@txString = "sfc-swilt"
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) standard"
plots(1) = gsn_csm_contour(wks,var2(::-1,:)*1.0,res)
res@tiMainString = "(c) mrd"
plots(2) = gsn_csm_contour(wks,var3({:-60.:-1},:)*1.0,res)
gsn_panel(wks,(/plots/),(/1,3/),pres)
print("finishing plotting sfc-swilt")
delete(res@cnLevels)
delete(pres@cnLevels)
delete(var1)
delete(var2)
delete(var3)

do var_num = 0,11
print(var_name2(var_num))
var1   = f->$var_name2(var_num)$
var2   = f2->$var_name2(var_num)$

if var_num .eq. 0 then
  var3   = lonFlip(f3->$var_name2(var_num)$)
else
  var3   = f3->$var_name2(var_num)$
end if

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude


var2!0 = "lat"
var2!1 = "lon"
var2&lat = f2->latitude
var2&lon = f2->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

if var_num .eq. 0 then
  res@cnLevels = fspan(0.,18.,19)
  pres@cnLevels = fspan(0.,18.,19)
else if var_num .eq. 1 then
  res@cnLevels = fspan(-1.,0,11)
  pres@cnLevels = fspan(-1.,0,11)
else if var_num .eq. 2 then
  res@cnLevels = fspan(0.2,0.7,21)
  pres@cnLevels = fspan(0.2,0.7,21)
else if var_num .eq. 3 then
  res@cnLevels = fspan(0.,0.5,21)
  pres@cnLevels = fspan(0.,0.5,21)
else if var_num .eq. 4 then
  res@cnLevels = fspan(0.,0.5,21)
  pres@cnLevels = fspan(0.,0.5,21)
else if var_num .eq. 5 then
  res@cnLevels = fspan(0.,0.03,31)
  pres@cnLevels = fspan(0.,0.03,31)
else if var_num .eq. 6 then
  res@cnLevels = fspan(800.,2000.,25)
  pres@cnLevels = fspan(800.,2000.,25)
else if var_num .eq. 7 then
  res@cnLevels = fspan(1.,16.,16)
  pres@cnLevels = fspan(1.,16.,16)
else if var_num .eq. 8 then
  res@cnLevels = fspan(1.,8.,8)
  pres@cnLevels = fspan(1.,8.,8)
else if var_num .eq. 9 then
  res@cnLevels = fspan(0.,0.35,15)
  pres@cnLevels = fspan(0.,0.35,15)
else if var_num .eq. 10 then
  res@cnLevels = fspan(800.,1700.,19)
  pres@cnLevels = fspan(800.,1700.,19)
else if var_num .le. 11 then
  res@cnLevels = fspan(0.,1.,21)
  pres@cnLevels = fspan(0.,1.,21)
end if
end if
end if
end if
end if
end if
end if
end if
end if
end if
end if
end if
pres@txString = var_name2(var_num)
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) standard"
if var_num .eq. 1 then
   plots(1) = gsn_csm_contour(wks,abs(var2(::-1,:))*(-1.0),res)
else
   plots(1) = gsn_csm_contour(wks,var2(::-1,:)*1.0,res)
end if
res@tiMainString = "(c) mrd"
plots(2) = gsn_csm_contour(wks,var3({:-60.:-1},:)*1.0,res)
gsn_panel(wks,(/plots/),(/1,3/),pres)
print("finishing plot "+var_name2(var_num))
delete(res@cnLevels)
delete(pres@cnLevels)
delete(var1)
delete(var2)
delete(var3)

end do


res@cnLevels = fspan(0.,1.,21)
pres@cnLevels = fspan(0.,1.,21)
print(var_name2(12))
var1   = f->$var_name2(12)$
var2   = dim_avg_n_Wrap(f2->$var_name2(12)$,0)
var3   = f3->$var_name2(12)$

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude


var2!0 = "lat"
var2!1 = "lon"
var2&lat = f2->latitude
var2&lon = f2->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

pres@txString = var_name2(12)
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) standard"
if var_num .eq. 1 then
   plots(1) = gsn_csm_contour(wks,abs(var2(::-1,:))*(-1.0),res)
else
   plots(1) = gsn_csm_contour(wks,var2(::-1,:)*1.0,res)
end if
res@tiMainString = "(c) mrd"
plots(2) = gsn_csm_contour(wks,var3({:-60.:-1},:)*1.0,res)
gsn_panel(wks,(/plots/),(/1,3/),pres)
print("finishing plot "+var_name2(var_num))
delete(res@cnLevels)
delete(pres@cnLevels)
delete(var1)
delete(var2)
delete(var3)


do var_num = 13,15
print(var_name2(var_num))

if var_num .eq. 13 then
  res@cnLevels = fspan(0.,5.,21)
  pres@cnLevels = fspan(0.,5.,21)
else if var_num .eq. 14 then
  res@cnLevels = fspan(0.,6.,31)
  pres@cnLevels = fspan(0.,6.,31)
else if var_num .eq. 15 then
  res@cnLevels = fspan(0.,2.,21)
  pres@cnLevels = fspan(0.,2.,21)
end if
end if
end if

var1   = dim_avg_n_Wrap(f->$var_name2(var_num)$,0)
var2   = dim_avg_n_Wrap(f2->$var_name2(var_num)$,0)
var3   = dim_avg_n_Wrap(f3->$var_name2(var_num)$,0)

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude


var2!0 = "lat"
var2!1 = "lon"
var2&lat = f2->latitude
var2&lon = f2->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

pres@txString = var_name2(var_num)
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) standard"
if var_num .eq. 1 then
   plots(1) = gsn_csm_contour(wks,abs(var2(::-1,:))*(-1.0),res)
else
   plots(1) = gsn_csm_contour(wks,var2(::-1,:)*1.0,res)
end if
res@tiMainString = "(c) mrd"
plots(2) = gsn_csm_contour(wks,var3({:-60.:-1},:)*1.0,res)
gsn_panel(wks,(/plots/),(/1,3/),pres)
print("finishing plot "+var_name2(var_num))

delete(var1)
delete(var2)
delete(var3)
delete(res@cnLevels)
delete(pres@cnLevels)
end do

do var_num = 16,17
print(var_name2(var_num))

if var_num .eq. 16 then
res@cnLevels = fspan(0.,0.7,15)
pres@cnLevels = fspan(0.,0.7,15)
else if var_num .eq. 17 then
res@cnLevels = fspan(190.,300.,25)
pres@cnLevels = fspan(190.,300.,25)
end if
end if 
var1   = dim_avg_n_Wrap(dim_avg_n_Wrap(f->$var_name2(var_num)$,0),0)
var2   = dim_avg_n_Wrap(dim_avg_n_Wrap(f2->$var_name2(var_num)$,0),0)
var3   = dim_avg_n_Wrap(dim_avg_n_Wrap(f3->$var_name2(var_num)$,0),0)

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude


var2!0 = "lat"
var2!1 = "lon"
var2&lat = f2->latitude
var2&lon = f2->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

pres@txString = var_name2(var_num)
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) standard"
if var_num .eq. 1 then
   plots(1) = gsn_csm_contour(wks,abs(var2(::-1,:))*(-1.0),res)
else
   plots(1) = gsn_csm_contour(wks,var2(::-1,:)*1.0,res)
end if
res@tiMainString = "(c) mrd"
plots(2) = gsn_csm_contour(wks,var3({:-60.:-1},:)*1.0,res)
gsn_panel(wks,(/plots/),(/1,3/),pres)
print("finishing plot "+var_name2(var_num))

delete(var1)
delete(var2)
delete(var3)
delete(res@cnLevels)
delete(pres@cnLevels)
end do

do var_num = 18,27
print(var_name2(var_num))


if var_num .eq. 18 then
res@cnLevels = fspan(0.,1.,11)
pres@cnLevels = fspan(0.,1.,11)
else if var_num .eq. 19 then
res@cnLevels = fspan(1.,18.,19)
pres@cnLevels = fspan(1.,18.,19)
else
res@cnLevels = fspan(0.,1.,21)
pres@cnLevels = fspan(0.,1.,21)
end if 
end if



var1   = f->$var_name2(var_num)$
var3   = f3->$var_name2(var_num)$

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

pres@txString = var_name2(var_num)
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) mrd"
plots(1) = gsn_csm_contour(wks,var3({:-60.:-1},:)*1.0,res)
gsn_panel(wks,(/plots(0:1)/),(/1,2/),pres)
print("finishing plot "+var_name2(var_num))

delete(var1)
delete(var3)
delete(res@cnLevels)
delete(pres@cnLevels)
end do

end
