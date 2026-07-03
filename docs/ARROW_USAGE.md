# Drawing Arrows in VMD

This repository includes scripts for drawing vector arrows in VMD. The simple
example is in `arrow1/`, and the example for generating many arrows is in
`arrow2/`.

## Requirements

- VMD
- Python for `arrow2/pca_tcl_arrow.py`

## Basic Usage: Drawing a Few Arrows

The basic arrow-drawing script is:

```text
arrow1/vector.tcl
```

Open the sample PDB file from the command line:

```sh
cd arrow1
vmd -pdb 2igd.pdb
```

In the VMD console, or from `Extensions` > `Tk Console`, load the Tcl script:

```tcl
source vector.tcl
```

The arrows should appear in the VMD display.

## How `vector.tcl` Works

The procedure at the top of `vector.tcl` defines the arrow shape:

```tcl
proc vmd_draw_arrow {mol start delta} {
	set end [vecadd $start [vecscale 5 $delta]]
	set middle [vecadd $start [vecscale 0.7 [vecsub $end $start]]]
	graphics $mol cylinder $start $middle radius 0.30
	graphics $mol cone $middle $end radius 0.50
}
```

The values in `set end`, `set middle`, and the cylinder/cone radii control the
arrow length and shape. Adjust these numbers and reload the script in VMD to
check the effect.

The atom selection is defined here:

```tcl
set sel [atomselect top " serial 10 to 12 or serial 15 to 16 or serial 100 or serial 120"]
```

This example selects atoms by `serial`, but any normal VMD atom-selection syntax
can be used. For example, selections do not have to be based on serial numbers.

The vector data is defined here:

```tcl
set v { {1 1 1} {1 1 1} {1 1 1} {0.5 0.7 0.9} {0.5 0.7 0.9} {2 2 2} {-2 -2 -2} }
```

Each vector corresponds to one selected atom. The arrow starts from the selected
atom position and points in the direction of the corresponding vector.

The following block filters out short arrows:

```tcl
set vl_min [expr $vl_max / 10.0]
#set vl_min 0
```

By default, arrows shorter than one tenth of the longest vector are not drawn.
If you want to draw every arrow, comment out the first line and uncomment the
second line:

```tcl
#set vl_min [expr $vl_max / 10.0]
set vl_min 0
```

## Drawing Many Arrows

For many arrows, such as vectors from normal mode analysis or principal
component analysis, use the Python script:

```text
arrow2/pca_tcl_arrow.py
```

This script generates a VMD Tcl script from a template Tcl file and a vector
data file.

## Vector Data Format

Prepare a vector data file such as:

```text
arrow2/ev1.vector
```

The file should list vector components one value per line, in this order:

```text
1x
1y
1z
2x
2y
2z
3x
3y
3z
...
```

For example, `1x` is the x component of the first arrow, and `2y` is the y
component of the second arrow. In the included `ev1.vector` example, there are
227 coarse-grained particles. Each particle has x, y, and z components, so the
file contains 681 vector-component lines plus one comment line.

Lines containing `#` are treated as comments and ignored by
`pca_tcl_arrow.py`.

## Generating a Tcl Script for Many Arrows

Run the script without enough arguments to show the usage message:

```sh
cd arrow2
./pca_tcl_arrow.py
```

To generate the included example Tcl script:

```sh
./pca_tcl_arrow.py template.tcl ev1.vector 1 227 ev1.tcl
```

This creates:

```text
ev1.tcl
```

The arguments mean:

```text
template.tcl   Template Tcl file
ev1.vector     Vector data file
1 227          Serial ID range of atoms where arrows will be drawn
ev1.tcl        Output Tcl file for VMD
```

If the atoms are not in one continuous range, provide multiple serial-ID ranges.
For example:

```sh
./pca_tcl_arrow.py template.tcl ev1.vector 1 10 15 18 ev1.tcl
```

This selects atoms with serial IDs 1 through 10 and 15 through 18.

## Loading the Generated Arrows in VMD

After generating `ev1.tcl`, open the sample VMD session:

```sh
vmd -e trna.vmd
```

Then load the generated Tcl script from the VMD console or Tk Console:

```tcl
source ev1.tcl
```

The arrows should appear in the VMD display.

## Notes

- The number of selected atoms should match the number of vectors.
- The arrow scaling is controlled in `template.tcl` by the `vecscale` value in
  `set end`.
- The generated Tcl file uses the same short-arrow filtering logic as
  `arrow1/vector.tcl`.
- To remove existing graphics in VMD before redrawing, run:

```tcl
graphics top delete all
```
