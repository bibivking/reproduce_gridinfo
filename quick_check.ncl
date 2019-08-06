;******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

begin

casename = (/\
"/srv/ccrc/data45/z3509830/CABLE_runs/CABLE_site_runs/CABLE_AUX-dev/offline/CABLE_UNSW_GSWP3_gridinfo_0.5x0.5.nc",\
             "gridinfo_mmy_MD_elev_orig_std_mask.nc",\
             "gridinfo_mmy_MD_elev_orig_std_avg-sand_mask.nc"\
             /)

f1 = addfile (casename(0),"r")
;f2 = addfile (casename(1),"r")

var1 = f1->clay;(f1->sand+f1->sand2)/2.
;var2 = f2->sand

pic = "var_check"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
;"BlueWhiteOrangeRed") ;"BlueYellowRed")             ;����ɫ��

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True                
res@tmBorderThicknessF = 3.0
res@lbLabelBarOn       = True
res@cnLinesOn          = False
 plot = gsn_csm_contour(wks,var1,res)
; plot = gsn_csm_contour(wks,var2,res)
; plot = gsn_csm_contour(wks,(var1-var2),res)

end 

