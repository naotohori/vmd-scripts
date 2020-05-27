#######################################################################
# Modified from view_change_render.tcl by Naoto Hori
#
######### The credit for the original version is
######### version 1.1b4
######### Barry Isralewitz, Jordi Cohen
######### Oct 2003; updated Feb 2007 
######### barryi@ks.uiuc.edu
#
# See view_change_render.tcl which is supposed to work together 
# with this script.

proc move_vp_movie {start_frame start end_frame end args} {
  global viewpoints 
  set pi 3.1415926535
  
  set smooth 1
  #set tumble 0
  set ninja  0
  #set render 0
  set render $::VCR::render

  #if {[lsearch $args "smooth"] > -1}  {set smooth 1}  ;#default
  #if {[lsearch $args "sharp"] > -1} {set smooth 0}
  #if {[lsearch $args "tumble"] > -1}  {set tumble 1}
  #if {[lsearch $args "ninja"] > -1}   {set ninja 1}
  #if {[lsearch $args "-render"] > -1} {set render 1}  ;# only for use by move_vp_render

  set morph_frames [expr $end_frame - $start_frame + 1]
  
  #if {$render} {set framenum $::VCR::first_frame_num}
  #if {$render} {set framenum $start_frame}
  
  if {$start == "here" || $end == "here"} {save_vp "here"}
            
  foreach mol [molinfo list] {
    if [info exists viewpoints($start,$mol,0)] {
      set old_rotate($mol)  $viewpoints($start,$mol,0)
      set old_center($mol) $viewpoints($start,$mol,1)
      set old_scale($mol) $viewpoints($start,$mol,2)
      set old_global($mol)  $viewpoints($start,$mol,3)
    } else {
      puts "Starting view $start was not saved" 
    }

    if [info exists viewpoints($end,$mol,0)] {
      set new_rotate($mol)  $viewpoints($end,$mol,0)
      set new_center($mol) $viewpoints($end,$mol,1)
      set new_scale($mol) $viewpoints($end,$mol,2)
      set new_global($mol)  $viewpoints($end,$mol,3)
    } else {
      puts "Starting view $start was not saved" 
    }

  
    #leave if don't have both viewpoints
    if {!([info exists viewpoints($start,$mol,0)] && [info exists viewpoints($end,$mol,0)])} {
      error "move_vp_render failed, don't have both start and end viewpoints"
    }
    
    set begin_euler [matrix_to_euler $old_rotate($mol)]
    set end_euler   [matrix_to_euler $new_rotate($mol)]
    
    set diff [vecsub $end_euler $begin_euler]
    
    
    # Make sure to take the quickest path!
    set f [expr 1./$pi]
    
    for {set i 0} {$i < 3} {incr i} {
      if  {[lindex $diff $i] > $pi} {
        set end_euler [lreplace $end_euler $i $i [expr [lindex $end_euler $i] -2.*$pi]]
      } elseif {[lindex $diff $i] < [expr -$pi]} {
        set end_euler [lreplace $end_euler $i $i [expr 2.*$pi + [lindex $end_euler $i]]]
      }
    }
    
    if {$ninja} {
      set end_euler [lreplace $end_euler 2 2 [expr 2.*$pi + [lindex $end_euler 2]]]
    }

    set needed_center($mol) [sub_mat  $new_center($mol) $old_center($mol)]
    set needed_scale($mol)  [sub_mat  $new_scale($mol)  $old_scale($mol)]
    set needed_global($mol) [sub_mat  $new_global($mol) $old_global($mol)]
  }
  
  set j 0
  if {$start == "here"} {set j 1}   

  set fr $start_frame

  #for {set j $firstj} {$j<= ($morph_frames - 1)} {incr j} {
  #}
  while {$fr <= $end_frame} {
    foreach mol [molinfo list] {
      #set scaling to apply for this individual frame
      if {$smooth} {
        #accelerate smoothly to start and stop 
        set theta [expr 3.1415927 * (0.0 + $j)/($morph_frames - 1)] 
        set scale_factor [expr 0.5*(1 - cos($theta))]
      } else {
        #infinite acceleration to start and stop
        set scale_factor [expr (0.0 + $j)/($morph_frames - 1)] 
      }
    
      if {$j == $morph_frames} {
        #avoid roundoff errors by ending in correct position
        set current_rotate($mol) $new_rotate($mol)
        set current_center($mol) $new_center($mol)
        set current_scale($mol)  $new_scale($mol)
        set current_global($mol) $new_global($mol)
      } else {
        set euler {}
        set random 0.
        #if {$tumble} {set random 0.1} 
        lappend euler [expr (1.-$scale_factor)*[lindex $begin_euler 0] + $scale_factor*[lindex $end_euler 0] + $random*rand()]
        lappend euler [expr (1.-$scale_factor)*[lindex $begin_euler 1] + $scale_factor*[lindex $end_euler 1] + $random*rand()]
        lappend euler [expr (1.-$scale_factor)*[lindex $begin_euler 2] + $scale_factor*[lindex $end_euler 2] + $random*rand()]
        set current_rotate($mol) [euler_to_matrix $euler]
  
        set current_center($mol) [add_mat $old_center($mol) [scale_mat $needed_center($mol) $scale_factor]]
        set current_scale($mol)  [add_mat $old_scale($mol)  [scale_mat $needed_scale($mol)  $scale_factor]]
        set current_global($mol) [add_mat $old_global($mol) [scale_mat $needed_global($mol) $scale_factor]]
      }
      
      molinfo $mol set rotate_matrix $current_rotate($mol)
      molinfo $mol set center_matrix $current_center($mol)
      molinfo $mol set scale_matrix $current_scale($mol)
      molinfo $mol set global_matrix $current_global($mol)
    }

    animate goto $fr

    graphics top delete all
    #eval add_time $fr
    eval add_captions $fr

    display update
    
    if {$render} {
      set frametext [justifysix $::VCR::movieframe]
      render Tachyon [file join $::VCR::dirName $::VCR::filePrefixName.$frametext.dat]  
      puts "Rendering frame [file join $::VCR::dirName $::VCR::filePrefixName.$frametext.dat]"

      puts $::VCR::logfile "$::VCR::movieframe $fr"
    }

    incr ::VCR::movieframe
    set frame_incr [eval frame_rate $fr]
    incr fr $frame_incr
    incr j $frame_incr
  }
}

proc justifysix {justify_frame} {
  if { $justify_frame < 1 } { 
    set frametext "000000"
  } elseif { $justify_frame < 10 } {
    set frametext "00000$justify_frame"
  } elseif {$justify_frame < 100} {
    set frametext "0000$justify_frame"
  } elseif {$justify_frame <1000} {
    set frametext "000$justify_frame"
  } elseif {$justify_frame <10000} {
    set frametext "00$justify_frame"
  } elseif {$justify_frame <100000} {
    set frametext "0$justify_frame"
  }  else {
    set frametext $justify_frame
  }
  return $frametext
  
}

proc frame_rate {iframe} {

  if { $iframe >= 5800 && $iframe <= 14400 } {
    return 3
  }

  return 1
}

proc add_captions {iframe} {
  
  if {$::VCR::render == 1} {
    set textsize 0.5
    set textthickness 1.2
  } else {
    set textsize 3.0
    set textthickness 4.0
  }

  # P7
  if { $iframe >= 900  && $iframe <= 1200 } {

    graphics top color cyan
    set arrow_start {0 -45 25}
    set arrow_end {20 -20 30}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {-5 -50 25} "P7" size $textsize thickness $textthickness
  } 

  # P6
  if { $iframe >= 2200  && $iframe <= 2500 } {

    graphics top color 12
    set arrow_start {-40 -35 -15}
    set arrow_end {-20 -25 -15}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {-45 -40 -15} "P6" size $textsize thickness $textthickness
  } 

  # TH
  if { $iframe >= 3750  && $iframe <= 4000 } {

    graphics top color 29
    set arrow_start {28 -38 0}
    set arrow_end {10 -15 0}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {30 -40 0} "TH" size $textsize thickness $textthickness
  } 

  # TL9-TR5
  if { $iframe >= 4100  && $iframe <= 4400 } {

    graphics top color black
    set arrow_start {22 65 0}
    set arrow_end {5 50 0}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {25 70 0} "TL9-TR5" size $textsize thickness $textthickness
  } 

  # P3
  if { $iframe >= 5200  && $iframe <= 5600} {

    graphics top color 23
    set arrow_start {-15 -60 0}
    set arrow_end {-5 -25 10}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {-20 -70 0} "P3" size $textsize thickness $textthickness
  } 

  # TL2-TR8
  if { $iframe >= 14500  && $iframe <= 15000 } {

    graphics top color black
    set arrow_start {-42 -55 0}
    set arrow_end {-28 -30 0}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {-80 -70 0} "TL9-TR5" size $textsize thickness $textthickness
  } 
}

proc add_time {iframe} {
  graphics top color black
  set t [expr $iframe * 0.0015]
  #graphics top text {40 -100 0} "t = 0.0 ms" size 2 thickness 3
  graphics top text {40 -100 0} [format "t = %5.1f ms" $t] size 2 thickness 3
}
      
proc calc_middle {s e} {
  
  return m
}

