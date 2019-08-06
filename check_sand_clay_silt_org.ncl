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
         "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_MD_elev_orig_std_avg-sand_mask.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5_site.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/GSWP3_gwmodel_parameters.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/gridinfo_CSIRO_1x1.nc"\
           /)
var_name1= (/"T_SAND","S_SAND","T_CLAY","S_CLAY","T_SILT","S_SILT","T_OC","S_OC"/)
var_name2= (/"sand","silt","clay","organic","sand2","silt2","clay2","organic2"/)

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

casename = "MD_elev_orig_avg-sand"

pic = "check-"+casename
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
res@gsnDraw       = True  ; Don't draw plots;
res@gsnFrame      = True
res@lbLabelBarOn  = True;False
pres@lbLabelBarOn = False;True


f1 = addfile(file_name(0)+"/T_SAND.nc4","r")
temp  = f1->T_SAND;(1000:1500,2000:2500)
temp  = 0.
temp1 = temp


do var_num = 0,5
f1 = addfile(file_name(0)+"/"+var_name1(var_num)+".nc4","r")
if mod(var_num,2) .eq. 0 then
  temp = temp + f1->$var_name1(var_num)$;(1000:1500,2000:2500)
else
  temp1 = temp1 + f1->$var_name1(var_num)$;(1000:1500,2000:2500)
end if
end do

plots = gsn_csm_contour(wks,temp,res)
plots = gsn_csm_contour(wks,temp1,res)

f2 = addfile(file_name(1),"r")
var1 = f2->sand +f2->clay +f2->silt
var2 = f2->sand2+f2->clay2+f2->silt2
plots = gsn_csm_contour(wks,var1,res)
plots = gsn_csm_contour(wks,var2,res)

delete(var1)
delete(var2)

f2 = addfile(file_name(2),"r")
var1 = f2->sand+f2->clay+f2->silt
var2 = f2->sand2+f2->clay2+f2->silt2
plots = gsn_csm_contour(wks,var1,res)
plots = gsn_csm_contour(wks,var2,res)
delete(var1)
delete(var2)

f2 = addfile(file_name(3),"r")
var1 = f2->sand_vec(5,:,:)+f2->clay_vec(5,:,:)+f2->silt_vec(5,:,:)
plots = gsn_csm_contour(wks,var1,res)

end
