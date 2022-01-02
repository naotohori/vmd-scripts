#!/bin/sh

if [ ! -d "./imagesTIS" ]; then
   mkdir imagesTIS
fi
if [ ! -d "./imagesMg" ]; then
   mkdir imagesMg
fi

"$VMDPATH" -e azo.TIS.vmd -dispdev text -eofexit < renderTIS.tcl > renderTIS.log

"$VMDPATH" -e azo.Mg.vmd -dispdev text -eofexit < renderMg.tcl > renderMg.log
