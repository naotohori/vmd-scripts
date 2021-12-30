set mol 0

# Number of frames
set num_steps [molinfo $mol get numframes]

# use the last frame for the reference
set reference [atomselect $mol "residue 0 to 195" frame $num_steps]

# the frame being compared
set compare [atomselect $mol "residue 0 to 195"]

set to_be_moved [atomselect $mol "all"]

for {set frame 0} {$frame < $num_steps - 1} {incr frame} {
        # get the correct frame
        $compare frame $frame

        # compute the transformation
        set trans_mat [measure fit $compare $reference]

        # do the alignment
        $to_be_moved frame $frame
        $to_be_moved move $trans_mat

        ## compute the RMSD
        #set rmsd [measure rmsd $compare $reference]
        ## print the RMSD
        #puts "RMSD of $frame is $rmsd"
}
