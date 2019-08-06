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
         ;"/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/GSWP3_gwmodel_parameters.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5.nc",\;_site
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/gridinfo_CSIRO_1x1.nc"\
           /)
var_name2= (/"sucs","ssat","sfc","swilt","hyds","watr"/)

;_____________________ Open file ________________________
casename ="MD_elev_orig_std_avg-sand_mask"
f  = addfile("gridinfo_mmy_"+casename+".nc","r")
f2 = addfile(file_name(0),"r")
f3 = addfile(file_name(1),"r")

; ______________________ sfc - swilt _____________________
var1   = f->sfc_vec
var1   = var1 - f->swilt_vec
;var2   = f2->sfc_vec
;var2   = var2 - f2->swilt_vec
var2   = f2->sfc(:,:);lonFlip()
var2   = var2 - f2->swilt(:,:);lonFlip()
var3   = f3->sfc
var3   = var3 - f3->swilt
var1!0 = "layer"
var1!1 = "lat"
var1!2 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude

;var2!0 = "layer"
;var2!1 = "lat"
;var2!2 = "lon"
var2!0 = "lat"
var2!1 = "lon"
var2&lat = f->latitude
var2&lon = f->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

; __________________________ PLOT SETTING ____________________________
casename = "MD_elev_orig_std_avg-sand_mask"

pic = "check-"+casename
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True                            ;???
res@tmBorderThicknessF = 3.0

res@gsnDraw            = False  ; Don't draw plots
res@gsnFrame           = False  ; ?????
res@lbLabelBarOn       = False

;************** ????labelbar ***************
res@lbBoxLinesOn       = True                       ;???lbar box ????
res@lbTitleFont        = 25
res@lbLabelFont        = 25
res@lbTitleFontHeightF = 0.013
res@lbLabelFontHeightF = 0.013
res@txString           = ""
res@tmXBLabelFont      = 25 ;Sets the font index for the bottom X-Axis labels.
res@tmYLLabelFont      = 25

;*************** ???????? *****************
res@cnLinesOn          = False                       ; ???????????
res@cnLineColor        = "black"
res@cnLineThicknessF   = 1.5
res@cnLineLabelsOn     = False
res@gsnMaximize        = False
res@cnExplicitLabelBarLabelsOn = True   ;?
res@cnLevelSelectionMode = "ExplicitLevels"

;************ ?????????????¦¶ **************
res@tmXBLabelFontThicknessF = 0.015
res@tmYLLabelFontThicknessF = 0.015
res@tmXBLabelFontHeightF = 0.015
res@tmYLLabelFontHeightF = 0.015
res@tmYLMode  = "Explicit"
res@tmXBMode  = "Explicit"

  A = -60.
  B = 90.
  C = 0.
  D = 360.
res@trYMinF   = A
res@trYMaxF   = B
res@mpMinLatF = A
res@mpMaxLatF = B
res@trXMinF   = C
res@trXMaxF   = D
res@mpMinLonF = C
res@mpMaxLonF = D

res@mpCenterLonF       = 160
res@tmYLValues=(/60,30,0,-30,-60/)
res@tmYLLabels=(/"60~S~o~N~N","30~S~o~N~N","0~S~o~N~","30~S~o~N~S","60~S~o~N~S"/)
res@tmXBValues=(/240,300,0,60,120,180/)
res@tmXBLabels=(/"120~S~o~N~W","60~S~o~N~W","0~S~o~N~","60~S~o~N~E","120~S~o~N~E","180~S~o~N~"/)

;**************** ????????? *****************
pres                    = True                                      ; ???? panel resources.
pres@gsnMaximize        = True
pres@gsnPanelLabelBar   = True                    ; ???? panel labelbar.
pres@cnLevelSelectionMode = "ExplicitLevels" ;"ManualLevels"
pres@lbBoxLinesOn       = True                       ;???lbar box ????
pres@lbTitleFont        = 25
pres@lbLabelFont        = 25
pres@lbTitleFontHeightF = 0.013
pres@lbLabelFontHeightF = 0.013

plots = new(2,graphic)

levels = (/0.02,0.04,0.06,0.08,0.1,0.12,0.14,0.16,0.18,0.2,0.22,0.24/)
res@cnLevels = levels
pres@cnLevels = levels
pres@txString = "Available Water Capacity"

res@tiMainString = "(a) Old"
;plots(1) = gsn_csm_contour_map(wks,dim_avg_n_Wrap(var2(:,::-1,:),0),res)
plots(0) = gsn_csm_contour_map(wks,var2({-60.:90},:),res)
delete(var1@units)
res@tiMainString = "(b) New"
plots(1) = gsn_csm_contour_map(wks,dim_avg_n_Wrap(var1(:,{-60.:90},:),0),res)
;res@tiMainString = "(c) CSIRO"
;plots(2) = gsn_csm_contour_map(wks,var3({:-60.:-1},:),res)
gsn_panel(wks,(/plots/),(/1,2/),pres)
print("finishing plotting sfc-swilt")
delete(res@cnLevels)
delete(pres@cnLevels)
delete(var1)
delete(var2)
;delete(var3)


end
