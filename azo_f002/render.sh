#!/bin/sh

mkdir imagesTIS
mkdir imagesMg

"$VMDPATH" -e azo.origin.TIS.vmd -dispdev text -eofexit < renderTIS.tcl > renderTIS.log

"$VMDPATH" -e azo.origin.Mg.vmd -dispdev text -eofexit < renderMg.tcl > renderMg.log
