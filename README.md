# VMD scripting

## Tips
Show the list of available render commands
```Tcl
render list
```

Delete graphics
```Tcl
graphics top delete all
```

## Drawing arrows

For detailed usage, including arrow shape parameters, atom selections, vector
data format, and generated Tcl scripts, see
[Drawing Arrows in VMD](docs/ARROW_USAGE.md).

### arrow1/

A simple TCL script to draw arrows.

```
$ vmd 2igd.pdb
[Tk console]$ source vector.tcl
```

### arrow2/

In case there are many arrows to be drawn (such as results of Nomal Mode Analysis and Principal Component Analysis), a python script pca_tcl_arrow.py can be used to generate a TCL script file.


```
$ ./pca_tcl_arrow.py  template.tcl  ev1.vector  1  227  ev1.tcl
$ vmd -e trna.vmd
[Tk console]$ source ev1.tcl
```

In this example, vector data for 227 points is stored in ev1.vector in order like {x1, y1, z1, x2, y2, z2 ...., x227, y227, z227}.

### mode_movie/

Visualize a PCA or normal-mode (NMA) motion vector as arrows plus an
oscillation movie. `make_mode_movie.py` (requires numpy) writes

- `PREFIX.pdb`: multi-model PDB, `x(k) = x_ref + A sin(2πk/N) v`
- `PREFIX_arrows.tcl`: one arrow per atom from `x_ref` to `x_ref + A v`.
  Settings at the top (color, scale, minimum length, radius) can be edited
  and the file re-sourced in VMD to redraw.

`view_mode.vmd` loads both and plays the movie.

Plain vector file (3N values, one column or `x y z` rows), amplitude in Å:

```
$ cd mode_movie
$ ./make_mode_movie.py ../arrow2/trna.pdb --vector ../arrow2/ev1.vector --amp 30 --arrow-min 1 -o trna_ev1
$ vmd -e view_mode.vmd -args trna_ev1
```

cpptraj eigenvector file (`diagmatrix` output), amplitude ±2σ with σ = √eigenvalue:

```
$ ./make_mode_movie.py ref.pdb --evecs evecs.dat --mode 1 --nsigma 2 -o pc1
$ vmd -e view_mode.vmd -args pc1
```

With `--evecs`, the average structure in the file is fitted onto the reference
PDB and the vector is rotated into the PDB frame, so the PDB does not need to be
in the frame used for the covariance matrix (disable with `--no-fit`).

Other options: `--atom-names CA` (use only matching PDB atoms, e.g. an all-atom
PDB with a CA-only vector), `--normalize`, `--flip` (invert the arbitrary sign
of the mode), `--nframes`, `--arrow-scale`, `--arrow-min`, `--arrow-radius`,
`--arrow-color`. See `./make_mode_movie.py -h`.


----
Special thanks to Mr. Fuyuki Sakai

## Credit and Disclaimer

Some of scripts here were adopted and modified from the script library in the official VMD website. https://www.ks.uiuc.edu/Research/vmd/script_library/ , thus all follow the original redistribution policy quoted below.

> VMD script library redistribution policy
> Scripts in the library are freely available for anyone to use and modify but may not be sold. They are distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. Should the software > prove defective YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
