#namespace eval ::VCR:: {}
source view_change_render.tcl
source view_change_render_my_functions.tcl

## Set any caption in this tcl file
source add_captions.tcl

## This view-points file must be prepared in advance using 
## "save_vp" and "write_vps" provided in view_change_render.tcl
source sample_view_points.tcl

## Alternatively, instead of tcl file, you can paste viewpoints as follows.
#set viewpoints(1,0,0) { {{0.5 0.06 0.86 0} {0.38 0.88 -0.28 0} {-0.78 0.47 0.41 0} {0 0 0 1}} }
#set viewpoints(1,0,1) { {{1 0 0 0} {0 1 0 0} {0 0 1 0} {0 0 0 1}} }
#set viewpoints(1,0,2) { {{0.002 0 0 0} {0 0.002 0 0} {0 0 0.002 0} {0 0 0 1}} }
#set viewpoints(1,0,3) { {{1 0 0 0} {0 1 0 0} {0 0 1 0} {0 0 0 1}} }
### These matrices correspond to rotate/center/scale/global matrix, respectively.
###  cf.  set viewpoints($view_num,$mol,0/1/2/3) [molinfo $mol get rotate/centre/scale/global_matrix]

## Set the size
display resize 500 500

## Swich either render (1) or not (0)
set ::VCR::render 0
#set ::VCR::render 1

if {$::VCR::render == 1} { 
  set ::VCR::dirName         ./
  set ::VCR::filePrefixName  sample
  set ::VCR::logfile [open ./sample_movie_vmd.log w]
  set ::VCR::movieframe 0
}

## Set fast-forward frames
proc frame_rate {iframe} {
  if { $iframe >= 5800 && $iframe <= 14400 } {
    # Skip 
    return 3
  }
  return 1
}

## Sequence of moves
pause 0 2 100
move_vp 0 0 1 200
move_vp 0 1 2 200
move_vp 0 2 0 200
#move_vp_movie    0    0  1000 1000 smooth
#move_vp_movie 1001 1000  2500 2500 smooth
#move_vp_movie 2501 2500  3750 3750 smooth
#move_vp_movie 3751 3750 16000 3750 smooth

if {$::VCR::render == 1} { 
  close $::VCR::logfile
}
