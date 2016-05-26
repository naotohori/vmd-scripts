proc vmd_draw_arrow {mol start delta} {
	set end [vecadd $start [vecscale 5 $delta]]
	set middle [vecadd $start [vecscale 0.7 [vecsub $end $start]]]
	graphics $mol cylinder $start $middle radius 0.30
	graphics $mol cone $middle $end radius 0.50
}

set sel [atomselect top " serial 10 to 12 or serial 15 to 16 or serial 100 or serial 120"]
set xyz [$sel get {x y z}]
set v { {1 1 1} {1 1 1} {1 1 1} {0.5 0.7 0.9} {0.5 0.7 0.9} {2 2 2} {-2 -2 -2} }

set vl_max 0
foreach b $v {
	set vl [veclength $b]
	if { $vl_max <= $vl } {
		set vl_max $vl
	}
}

set vl_min [expr $vl_max / 10.0]
#set vl_min 0

set dr_xyz {}
set dr_v {}
foreach a $xyz b $v {
	set vl [veclength $b]
	if { $vl >= $vl_min } {
		lappend dr_xyz $a
		lappend dr_v $b
	}
}

foreach a $dr_xyz b $dr_v {
	draw arrow $a $b
}
