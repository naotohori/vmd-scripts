#namespace eval ::VCR:: {}

source view_change_render.tcl
source view_change_render_my_functions.tcl

source f002_view_points.tcl

display resize 500 500

#set ::VCR::render 0
set ::VCR::render 1

if {$::VCR::render == 1} { 
  set ::VCR::dirName         ./
  set ::VCR::filePrefixName  f002
  set ::VCR::logfile [open ./f002_movie_vmd.log w]
  set ::VCR::movieframe 0
}

move_vp_movie 0 0 1000 1000 smooth
move_vp_movie 1001 1000 2500 2500 smooth
move_vp_movie 2501 2500 3750 3750 smooth
move_vp_movie 3751 3750 16000 3750 smooth

if {$::VCR::render == 1} { 
  close $::VCR::logfile
}
