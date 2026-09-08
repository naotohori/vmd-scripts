# Render evenly spaced trajectory frames using a saved VMD visual state.
# Defaults reproduce the comp9 dataset; command-line arguments override them.
#
# Run from the directory used to resolve relative paths in the VMD state.
# Usage:
#   vmd -dispdev text -size 800 600 -eofexit \
#       -e render_comp9_frames.tcl \
#       -args OUTPUT_DIRECTORY SAMPLE_COUNT RENDER_LIMIT \
#       STATE_FILE TRAJECTORY_FILE SOURCE_LAST_FRAME \
#       ALIGN_SELECTION SMOOTH_RADIUS IMAGE_WIDTH IMAGE_HEIGHT
#
# By default, the source trajectory contains 100,000 frames (indices
# 0--99,999). The default 180 samples make a 15-second GIF at 12 fps.
# After loading, all atoms in every frame are moved by a least-squares fit of
# the nucleic-acid heavy atoms to frame 0 of the top molecule.  This matches
# RMSD Trajectory Tool defaults: selection "nucleic", "noh" enabled,
# Reference mol "Top", trajectory reference frame 0, and ALIGN.
# Tachyon may pad the raw TGA height to a multiple of 16; crop it when making
# the GIF.  The command used for this dataset was:
#
#   ffmpeg -framerate 12 -i OUTPUT_DIRECTORY/frame_%04d.tga \
#     -filter_complex \
#     '[0:v]crop=800:600:0:4,split[a][b];[b]palettegen=stats_mode=diff[p];[a][p]paletteuse=dither=sierra2_4a:diff_mode=rectangle' \
#     -loop 0 data/processed/comp9_md_15s.gif

set output_dir "data/processed/comp9_md_frames"
set sample_count 180
set render_limit -1
set state_path "comp9.vmd"
set trajectory_path "compound9rank1_dry.nc"
set source_last_frame 99999
set align_selection "(nucleic) and noh"
set smooth_radius 5
set image_width 800
set image_height 600

if {$argc >= 1} {
    set output_dir [lindex $argv 0]
}
if {$argc >= 2} {
    set sample_count [lindex $argv 1]
}
if {$argc >= 3} {
    set render_limit [lindex $argv 2]
}
if {$argc >= 4} {
    set state_path [lindex $argv 3]
}
if {$argc >= 5} {
    set trajectory_path [lindex $argv 4]
}
if {$argc >= 6} {
    set source_last_frame [lindex $argv 5]
}
if {$argc >= 7} {
    set align_selection [lindex $argv 6]
}
if {$argc >= 8} {
    set smooth_radius [lindex $argv 7]
}
if {$argc >= 9} {
    set image_width [lindex $argv 8]
}
if {$argc >= 10} {
    set image_height [lindex $argv 9]
}

if {$sample_count < 2} {
    error "SAMPLE_COUNT must be at least 2"
}
if {$render_limit < 0 || $render_limit > $sample_count} {
    set render_limit $sample_count
}
if {$source_last_frame < 1} {
    error "SOURCE_LAST_FRAME must be at least 1"
}
if {$smooth_radius < 0} {
    error "SMOOTH_RADIUS must not be negative"
}

set state_file [open $state_path r]
set state_script [read $state_file]
close $state_file

set netcdf_load_commands [regexp -all -inline -line {^[ \t]*mol[ \t]+addfile[^\n]*[ \t]+type[ \t]+netcdf[^\n]*$} $state_script]
if {[llength $netcdf_load_commands] != 1} {
    error "Expected exactly one 'mol addfile ... type netcdf' command in $state_path; found [llength $netcdf_load_commands]"
}
set original_load_command [lindex $netcdf_load_commands 0]
set sampled_load_commands {
set render_source_frames {}
set render_loaded_frames {}
set loaded_frame_count 0
for {set sample_index 0} {$sample_index < $sample_count} {incr sample_index} {
    set source_frame [expr {int(round(double($sample_index) * double($source_last_frame) / double($sample_count - 1)))}]
    set window_first [expr {max(0, $source_frame - $smooth_radius)}]
    set window_last [expr {min($source_last_frame, $source_frame + $smooth_radius)}]

    mol addfile $trajectory_path type netcdf first $window_first last $window_last step 1 filebonds 1 autobonds 1 waitfor all

    lappend render_source_frames $source_frame
    lappend render_loaded_frames [expr {$loaded_frame_count + $source_frame - $window_first}]
    incr loaded_frame_count [expr {$window_last - $window_first + 1}]
}

set align_reference_frame 0
if {$align_selection eq ""} {
    puts "ALIGN_SKIPPED"
    flush stdout
} else {
    set align_reference [atomselect top $align_selection frame $align_reference_frame]
    set align_mobile [atomselect top $align_selection]
    set align_all [atomselect top "all"]

    puts "ALIGN_BEGIN selection={$align_selection} reference_molecule=top reference_frame=$align_reference_frame frames=$loaded_frame_count move_selection={all}"
    flush stdout
    for {set loaded_frame 0} {$loaded_frame < $loaded_frame_count} {incr loaded_frame} {
        if {$loaded_frame == $align_reference_frame} {
            continue
        }
        $align_mobile frame $loaded_frame
        $align_all frame $loaded_frame
        $align_all move [measure fit $align_mobile $align_reference]
    }
    $align_reference delete
    $align_mobile delete
    $align_all delete
    puts "ALIGN_COMPLETE frames=$loaded_frame_count"
    flush stdout
}
}

set state_script [string map [list $original_load_command $sampled_load_commands] $state_script]
puts "STATE_EVAL_BEGIN"
flush stdout
eval $state_script
puts "STATE_EVAL_COMPLETE"
flush stdout

file mkdir $output_dir
puts "OUTPUT_DIRECTORY_READY path=$output_dir"
flush stdout
if {[catch {axes location Off} axes_error]} {
    puts "AXES_WARNING message=$axes_error"
} else {
    puts "AXES_OFF_COMPLETE"
}
flush stdout

puts "RENDER_SETUP source_frames=[expr {$source_last_frame + 1}] samples=$sample_count render_limit=$render_limit resolution=${image_width}x${image_height}"
flush stdout

for {set sample_index 0} {$sample_index < $render_limit} {incr sample_index} {
    set source_frame [lindex $render_source_frames $sample_index]
    set loaded_frame [lindex $render_loaded_frames $sample_index]
    animate goto $loaded_frame
    display update

    set output_file [file join $output_dir [format "frame_%04d.tga" $sample_index]]
    puts "RENDER_FRAME sample=$sample_index source=$source_frame loaded=$loaded_frame output=$output_file"
    flush stdout
    render TachyonInternal $output_file ""
}

puts "RENDER_COMPLETE rendered=$render_limit"
flush stdout
quit
