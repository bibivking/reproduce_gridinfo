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
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5_site.nc",\
         "/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/gridinfo_CSIRO_1x1.nc"\
           /)


var_name2= (/\
              "drainage_density","drainage_dist",\
              "slope","slope_std",\
              "Sy","dtb","elevation","elevation_std",\
              "permeability","permeability_std",\
              "bch_vec","sucs_vec","ssat_vec","swilt_vec","sfc_vec","css_vec","hyds_vec",\
              "rhosoil_vec","cnsd_vec",\
              "sand_vec","clay_vec","silt_vec","org_vec",\ ; top 3 ->sand/clay/silt lower 3 ->sand2/clay2/silt2
              "watr"\
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

pic = "converge_elev"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
res@gsnDraw       = False  ; Don't draw plots;
res@gsnFrame      = False
res@lbLabelBarOn  = True;False
pres@lbLabelBarOn = False;True

f  = addfile("gridinfo_mmy.nc","r")
f2 = addfile(file_name(2),"r")
f3 = addfile(file_name(0),"r")



;______________________ sfc - swilt _______________________
var1   = dim_avg_n_Wrap(f->sfc_vec,0)
var1   = var1 - dim_avg_n_Wrap(f->swilt_vec,0)
var2   = f2->sfc
var2   = var2 - f2->swilt
var3   = dim_avg_n_Wrap(f3->sfc_vec,0)
var3   = var3 - dim_avg_n_Wrap(f3->swilt_vec,0)

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

res@cnLevels  = fspan(0.,0.22,12)
pres@cnLevels = fspan(0.,0.22,12)
pres@txString = "sfc-swilt"
res@tiMainString = "(a) reproduce"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)
res@tiMainString = "(b) standard"
plots(1) = gsn_csm_contour(wks,var2(::-1,:)*1.0,res)
res@tiMainString = "(c) mrd"
plots(2) = gsn_csm_contour(wks,var3({-60.:},:)*1.0,res)
gsn_panel(wks,(/plots/),(/1,3/),pres)
print("finishing plotting sfc-swilt")
delete(res@cnLevels)
delete(pres@cnLevels)
delete(var1)
delete(var2)
delete(var3)



;_____________________ others __________________________
do var_num = 0,23
print(var_num + " "+ var_name2(var_num))

if var_num .le. 9 then
var1   = f->$var_name2(var_num)$
var3   = lonFlip(f3->$var_name2(var_num)$)
else if var_num .gt. 9 then
var1   = dim_avg_n_Wrap(f->$var_name2(var_num)$,0)
var3   = lonFlip(dim_avg_n_Wrap(f3->$var_name2(var_num)$,0))
end if
end if

var1!0 = "lat"
var1!1 = "lon"
var1&lat = f->latitude
var1&lon = f->longitude

var3!0 = "lat"
var3!1 = "lon"
var3&lat = f3->latitude
var3&lon = f3->longitude

if var_num .eq. 10 then ;bch
  res@cnLevels = fspan(1.,16.,16)
  pres@cnLevels = fspan(1.,16.,16)
else if var_num .eq. 11 then ;sucs
  res@cnLevels = fspan(-1.,0,11)
  pres@cnLevels = fspan(-1.,0,11)
else if var_num .eq. 12 then ;ssat
  res@cnLevels = fspan(0.0,0.6,31)
  pres@cnLevels = fspan(0.0,0.6,31)
else if var_num .eq. 13 then ;swilt
  res@cnLevels = fspan(0.,0.4,21)
  pres@cnLevels = fspan(0.,0.4,21)
else if var_num .eq. 14 then ;sfc
  res@cnLevels = fspan(0.,0.4,21)
  pres@cnLevels = fspan(0.,0.4,21)
else if var_num .eq. 15 then ;css
  res@cnLevels = fspan(700.,1000,21)
  pres@cnLevels = fspan(700.,1000,21)
else if var_num .eq. 16 then ;hyds
  res@cnLevels = fspan(0.,0.03,16)
  pres@cnLevels = fspan(0.,0.03,16)
else if var_num .eq. 17 then ;rhosoil
  res@cnLevels = fspan(400.,1600.,13)
  pres@cnLevels = fspan(400.,1600.,13)
else if var_num .eq. 18 then ;cnsd
  res@cnLevels = fspan(0.1,0.3,21)
  pres@cnLevels = fspan(0.1,0.3,21)
else if var_num .lt. 22 then ;sand/silt/clay
  res@cnLevels = fspan(0.,1.,21)
  pres@cnLevels = fspan(0.,1.,21)
else if var_num .eq. 22 then
  res@cnLevels = fspan(0.,0.7,15)
  pres@cnLevels = fspan(0.,0.7,15)
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
res@tiMainString = "(a) converge"
plots(0) = gsn_csm_contour(wks,var1({:-60.:-1},:)*1.0,res)

res@tiMainString = "(b) mrd"
plots(1) = gsn_csm_contour(wks,var3({-60.:},:)*1.0,res)
gsn_panel(wks,(/plots(0:1)/),(/1,2/),pres)
print("finishing plot "+var_name2(var_num))
delete(res@cnLevels)
delete(pres@cnLevels)
delete(var1)
delete(var3)

end do

end
