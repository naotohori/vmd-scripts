# VMD scripting

## Drawing arrows

### arrow1/

A simple TCL script to draw arrows.

```
$ vmd 2igd.pdb
[Tk console]$ source vector1.tcl
```

### arrow2/

In case there are many arrows to be drawn (such as results of Nomal Mode Analysis and Principal Component Analysis), a python script pca_tcl_arrow.py can be used to generate a TCL script file.


```
$ ./pca_tcl_arrow.py  template.tcl  ev1.vector  1  227  ev1.tcl
$ vmd -e trna.vmd
[Tk console]$ source ev1.tcl
```

In this example, vector data for 227 points is stored in ev1.vector in order like {x1, y1, z1, x2, y2, z2 ...., x227, y227, z227}.


----
Special thanks to Mr. Fuyuki Sakai


