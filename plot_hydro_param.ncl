;*******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

;______ From Mark Decker's code _____
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 1000000000 ;1000000000
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

f = addfile("gridinfo_mmy.nc","r")

bch   = f->bch
sfc   = f->sfc
ssat  = f->ssat
sucs  = f->sucs
swilt = f->swilt

; __________________________ PLOTTING ____________________________
res@gsnDraw       = False  ; Don't draw plots;
res@gsnFrame      = False
res@lbLabelBarOn  = True
pres@lbLabelBarOn = False

  f2 = addfile(file_name(1),"r")
  f3 = addfile(file_name(2),"r")

  res@cnLevels = fspan(0.,18.,19)
  pres@txString = "bch"
  ;res@tiMainString = "GSWP3_gwmodel_parameters_site"
  plots(0) = gsn_csm_contour(wks,bch({:-60.:-1},:),res)
  plots(1) = gsn_csm_contour(wks,f3->bch({::-1},:),res)
  plots(2) = gsn_csm_contour(wks,f2->bch({:-60.:-1},:),res); - bch)
  gsn_panel(wks,(/plots/),(/1,3/),pres)
  delete(res@cnLevels)
  print("finishing plotting bch")

  res@cnLevels = fspan(-1.,0,11)
  pres@txString = "sucs"
  plots(0) = gsn_csm_contour(wks,sucs({:-60.:-1},:),res)
  plots(1) = gsn_csm_contour(wks,f3->sucs({::-1},:),res)
  plots(2) = gsn_csm_contour(wks,f2->sucs({:-60.:-1},:),res); - bch)
  gsn_panel(wks,(/plots/),(/1,3/),pres)
  delete(res@cnLevels)
  print("finishing plotting sucs")

  res@cnLevels = fspan(0.,0.5,21)
  pres@txString = "ssat"
  plots(0) = gsn_csm_contour(wks,ssat({:-60.:-1},:),res)
  plots(1) = gsn_csm_contour(wks,f3->ssat({::-1},:),res)
  plots(2) = gsn_csm_contour(wks,f2->ssat({:-60.:-1},:),res); - bch)
  gsn_panel(wks,(/plots/),(/1,3/),pres)
  delete(res@cnLevels)
  print("finishing plotting ssat")

  res@cnLevels = fspan(0.,0.5,21)
  pres@txString = "swilt"
  plots(0) = gsn_csm_contour(wks,swilt({:-60.:-1},:),res)
  plots(1) = gsn_csm_contour(wks,f3->swilt({::-1},:),res)
  plots(2) = gsn_csm_contour(wks,f2->swilt({:-60.:-1},:),res); - bch)
  gsn_panel(wks,(/plots/),(/1,3/),pres)
  delete(res@cnLevels)
  print("finishing plotting swilt")

  res@cnLevels = fspan(0.,0.5,21)
  pres@txString = "sfc"
  plots(0) = gsn_csm_contour(wks,sfc({:-60.:-1},:),res)
  plots(1) = gsn_csm_contour(wks,f3->sfc({::-1},:),res)
  plots(2) = gsn_csm_contour(wks,f2->sfc({:-60.:-1},:),res); - bch)
  gsn_panel(wks,(/plots/),(/1,3/),pres)
  delete(res@cnLevels)
  print("finishing plotting sfc")

  res@cnLevels = fspan(0.,0.22,12)
  pres@txString = "sfc-swilt"
  plots(0) = gsn_csm_contour(wks,sfc({:-60.:-1},:) - swilt({:-60.:-1},:),res)
  plots(1) = gsn_csm_contour(wks,f3->sfc({::-1},:)-f3->swilt({::-1},:),res)
  plots(2) = gsn_csm_contour(wks,f2->sfc({:-60.:-1},:)-f2->swilt({:-60.:-1},:),res); - bch)
  gsn_panel(wks,(/plots/),(/1,3/),pres)
  print("finishing plotting sfc-swilt")

end
