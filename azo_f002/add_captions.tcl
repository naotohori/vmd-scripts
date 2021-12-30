proc add_captions {iframe} {
  
  #if {$::VCR::render == 1} {
  #  set textsize 0.5
  #  set textthickness 1.2
  #} else {
    set textsize 3.0
    set textthickness 4.0
  #}

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
    set arrow_start {32 -40 0}
    set arrow_end {15 -12 0}
    set arrow_middle [vecadd $arrow_start [vecscale 0.7 [vecsub $arrow_end $arrow_start]]]
    graphics top cylinder $arrow_start $arrow_middle radius 2.0
    graphics top cone $arrow_middle $arrow_end radius 5.0
   
    graphics top text {35 -42 0} "TH" size $textsize thickness $textthickness
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
    set arrow_end {-10 -30 10}
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
