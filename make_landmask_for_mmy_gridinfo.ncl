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

casename = (/\
            "GADY-CABLE_orig",\
            "GADY-CABLE_orig_std",\
            "MD_elev_orig",\
            "MD_elev_orig_std",\
            "MD_elev_orig_std_avg-sand"\
           /)

file_name1 = "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_"+casename(4)+"_mask.nc"
file_name2 = "gridinfo_mmy_"+casename(4)+"_landmask.nc"

; ______________________________ Forming nc data ____________________________
fcp = addfile (file_name1,"r")
filo = file_name2

system("/bin/rm -f " + filo)    ; remove if exists
fout  = addfile (filo, "c")     ; open output file

; explicitly declare file definition mode. Improve efficiency.
setfileoption(fout,"DefineMode",True)

; create global attributes of the file
fAtt               = True            ; assign file attributes
fAtt@title         = "landmask file for gridinfo_mmy to run with GSWP3 data"
fAtt@source_file   = file_name1
fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( fout, fAtt )            ; copy file attributes

; predefine the coordinate variables and their dimensionality
; Note: to get an UNLIMITED record dimension, we set the dimensionality
; to -1 (or the actual size) and set the dimension name to True.

nlat   = 360 ;
nlon   = 720

dimNames = (/ "latitude", "longitude" /)
dimSizes = (/ nlat , nlon  /)
dimUnlim = (/ False, False /)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

; predefine the the dimensionality of the variables to be written out
print("Predefine")
filevardef(fout, "landsea",typeof(fcp->landsea),getvardims(fcp->landsea))
filevardef(fout, "latitude",typeof(fcp->latitude),getvardims(fcp->latitude))
filevardef(fout, "longitude",typeof(fcp->longitude),getvardims(fcp->longitude))

print("Copy attributes")
filevarattdef(fout,"landsea",fcp->landsea)
filevarattdef(fout,"latitude",fcp->latitude)
filevarattdef(fout,"longitude",fcp->longitude)
setfileoption(fout,"DefineMode",False)
print("Exit DefineMode")

fout->landsea   = fcp->landsea
fout->latitude  = fcp->latitude
fout->longitude  = fcp->longitude

end
