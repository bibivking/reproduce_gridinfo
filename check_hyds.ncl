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
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/GSWP3_gwmodel_parameters.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5.nc"\
           /)
var_name2= (/"hyds_vec","permeability"/)

;_____________________ Open file ________________________
casename ="MD_elev_orig_std_avg-sand_mask"
f  = addfile("/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_"+casename+".nc","r")
f2 = addfile(file_name(0),"r")
f3 = addfile(file_name(1),"r")

; ______________________ sfc - swilt _____________________
hyds_new   = f->ssat_vec(5,:,:)
GWhyds_new = f->Sy(:,:)
;f->permeability(:,:)*1000
hyds_old   = f2->hyds_vec(5,:,:)
GWhyds_old = f2->permeability(:,:)*1000


; __________________________ PLOT SETTING ____________________________
casename = "MD_elev_orig_std_avg-sand_mask"

pic = "check-"+casename
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"RedWhiteBlue") ;WhiteBlueGreenYellowRed

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True                            ;???
res@tmBorderThicknessF = 3.0

res@gsnDraw            = False  ; Don't draw plots
res@gsnFrame           = False  ; ?????
res@lbLabelBarOn       = True
;
; ;************** ????labelbar ***************
; res@lbBoxLinesOn       = True                       ;???lbar box ????
; res@lbTitleFont        = 25
; res@lbLabelFont        = 25
; res@lbTitleFontHeightF = 0.013
; res@lbLabelFontHeightF = 0.013
; res@txString           = ""
; res@tmXBLabelFont      = 25 ;Sets the font index for the bottom X-Axis labels.
; res@tmYLLabelFont      = 25

;*************** ???????? *****************
res@cnLinesOn          = False                       ; ???????????
res@cnLineColor        = "black"
res@cnLineThicknessF   = 1.5
res@cnLineLabelsOn     = False
res@gsnMaximize        = False
res@cnExplicitLabelBarLabelsOn = True   ;?
res@cnLevelSelectionMode = "ExplicitLevels"

;************ ?????????????�� **************
res@tmXBLabelFontThicknessF = 0.015
res@tmYLLabelFontThicknessF = 0.015
res@tmXBLabelFontHeightF = 0.015
res@tmYLLabelFontHeightF = 0.015
res@tmYLMode  = "Explicit"
res@tmXBMode  = "Explicit"
;
;   A = -60.
;   B = 90.
;   C = 0.
;   D = 360.
; res@trYMinF   = A
; res@trYMaxF   = B
; res@mpMinLatF = A
; res@mpMaxLatF = B
; res@trXMinF   = C
; res@trXMaxF   = D
; res@mpMinLonF = C
; res@mpMaxLonF = D
;
; res@mpCenterLonF       = 160
; res@tmYLValues=(/60,30,0,-30,-60/)
; res@tmYLLabels=(/"60~S~o~N~N","30~S~o~N~N","0~S~o~N~","30~S~o~N~S","60~S~o~N~S"/)
; res@tmXBValues=(/240,300,0,60,120,180/)
; res@tmXBLabels=(/"120~S~o~N~W","60~S~o~N~W","0~S~o~N~","60~S~o~N~E","120~S~o~N~E","180~S~o~N~"/)

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

plots = new(6,graphic)

;levels = (/-0.02,-0.01,-0.001,-0.0001,-0.00001,-0.000001, 0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.02 /)
;levels = (/0., 0.01, 0.02, /)
;res@cnLevels = levels
;pres@cnLevels = levels
pres@txString = "Available Water Capacity"

res@tiMainString = "(a) hyds"
plots(0) = gsn_csm_contour(wks,hyds_new,res)

res@tiMainString = "(b) hyds"
plots(1) = gsn_csm_contour(wks,hyds_old(::-1,:)*1.,res)

res@tiMainString = "(a) Old"
plots(2) = gsn_csm_contour(wks,GWhyds_new(:,:)*1.,res)

res@tiMainString = "(b) New"
plots(3) = gsn_csm_contour(wks,GWhyds_old(::-1,:)*1.,res)


res@tiMainString = "(a) Old"
plots(4) = gsn_csm_contour(wks,hyds_new*1.-GWhyds_new(:,:)*1.,res)

res@tiMainString = "(b) New"
plots(5) = gsn_csm_contour(wks,hyds_old(::-1,:)*1.-GWhyds_old(::-1,:)*1.,res)

gsn_panel(wks,(/plots/),(/3,2/),pres)
print("finishing plotting sfc-swilt")
delete(res@cnLevels)
delete(pres@cnLevels)


end
