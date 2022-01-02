## Set the size
display resize 1024 1024
display projection orthographic

#namespace eval ::VCR:: {}
source view_change_render.tcl
source view_change_render_my_functions.tcl

## Set any caption in this tcl file
#source add_captions_empty.tcl

## This view-points file must be prepared in advance using 
## "save_vp" and "write_vps" provided in view_change_render.tcl
source azo_f324.viewpoints.tcl

## Alternatively, instead of tcl file, you can paste viewpoints as follows.
#set viewpoints(1,0,0) { {{0.5 0.06 0.86 0} {0.38 0.88 -0.28 0} {-0.78 0.47 0.41 0} {0 0 0 1}} }
#set viewpoints(1,0,1) { {{1 0 0 0} {0 1 0 0} {0 0 1 0} {0 0 0 1}} }
#set viewpoints(1,0,2) { {{0.002 0 0 0} {0 0.002 0 0} {0 0 0.002 0} {0 0 0 1}} }
#set viewpoints(1,0,3) { {{1 0 0 0} {0 1 0 0} {0 0 1 0} {0 0 0 1}} }
### These matrices correspond to rotate/center/scale/global matrix, respectively.
###  cf.  set viewpoints($view_num,$mol,0/1/2/3) [molinfo $mol get rotate/centre/scale/global_matrix]

## Swich either render (1) or not (0)
#set ::VCR::render 0
set ::VCR::render 1

if {$::VCR::render == 1} { 
  set ::VCR::dirName         ./imagesMg/
  set ::VCR::filePrefixName  movie
  set ::VCR::logfile [open ./f324.Mg.vmd.log w]
  set ::VCR::movieframe 0
}


## Set fast-forward frames
proc frame_rate {iframe} {
  set rate_slow 1
  set rate_normal 5
  set rate_fast   8
  set rate_fastest 20
  if {                      $iframe <   1100 } { return $rate_normal }
  if { $iframe >=   1100 && $iframe <   1300 } { return $rate_slow }
  if { $iframe >=   1300 && $iframe <   6100 } { return $rate_normal }
  if { $iframe >=   6100 && $iframe <   6400 } { return $rate_slow }
  if { $iframe >=   6400 && $iframe <   8250 } { return $rate_normal }
  if { $iframe >=   8250 && $iframe <   8700 } { return $rate_slow }
  if { $iframe >=   8700 && $iframe <  66900 } { return $rate_fast }
  if { $iframe >=  66900 && $iframe <  67400 } { return $rate_slow }
  if { $iframe >=  67400 && $iframe <  72300 } { return $rate_normal }
  if { $iframe >=  72300 && $iframe <  72600 } { return $rate_slow }
  if { $iframe >=  72600 && $iframe < 107500 } { return $rate_fast }
  if { $iframe >= 107500 && $iframe < 107800 } { return $rate_slow }
  if { $iframe >= 107800 && $iframe < 109000 } { return $rate_fast }
  if { $iframe >= 109000                     } { return $rate_fastest }

  return 1
}

## All
move_vp_movie       0      0    1333   1333 smooth
move_vp_movie    1334   1333    6220   6220 smooth
move_vp_movie    6221   6220    8420   8420 smooth
move_vp_movie    8421   8420    9000   9000 smooth
move_vp_movie    9001   9000   10600  10600 smooth
move_vp_movie   10601  10600   12000  12000 smooth
move_vp_movie   12001  12000   17800  17800 smooth
move_vp_movie   17801  17800   25000  25000 smooth
move_vp_movie   25001  25000   30000  30000 smooth
move_vp_movie   30001  30000   35000  35000 smooth
move_vp_movie   35001  35000   40000  40000 smooth
move_vp_movie   40001  40000   45000  45000 smooth
move_vp_movie   45001  45000   50000  50000 smooth
move_vp_movie   50001  50000   55000  55000 smooth
move_vp_movie   55001  55000   60000  60000 smooth
move_vp_movie   60001  60000   65000  65000 smooth
move_vp_movie   65001  65000   67200  67200 smooth
move_vp_movie   67201  67200   70000  70000 smooth
move_vp_movie   70001  70000   72400  72400 smooth
move_vp_movie   72401  72400   75000  75000 smooth
move_vp_movie   75001  75000   80000  80000 smooth
move_vp_movie   80001  80000   85000  85000 smooth
move_vp_movie   85001  85000   90000  90000 smooth
move_vp_movie   90001  90000   95000  95000 smooth
move_vp_movie   95001  95000  100000 100000 smooth
move_vp_movie  100001 100000  105000 105000 smooth
move_vp_movie  105001 105000  110000 110000 smooth
move_vp_movie  110001 110000  115000 115000 smooth
move_vp_movie  115001 115000  120000 120000 smooth
move_vp_movie  120001 120000  125000 125000 smooth
move_vp_movie  125001 125000  130000 130000 smooth
move_vp_movie  130001 130000  135000 135000 smooth
move_vp_movie  135001 135000  140000 140000 smooth
move_vp_movie  140001 140000  145000 145000 smooth
move_vp_movie  145001 145000  150000 150000 smooth
move_vp_movie  150001 150000  155000 155000 smooth
move_vp_movie  155001 155000  160000 160000 smooth
move_vp_movie  160001 160000  165000 165000 smooth
move_vp_movie  165001 165000  170000 170000 smooth
move_vp_movie  170001 170000  175000 175000 smooth
move_vp_movie  175001 175000  180000 180000 smooth
move_vp_movie  180001 180000  185000 185000 smooth
move_vp_movie  185001 185000  190000 190000 smooth
move_vp_movie  190001 190000  195000 195000 smooth
move_vp_movie  195001 195000  200001 200001 smooth

if {$::VCR::render == 1} { 
  close $::VCR::logfile
}
