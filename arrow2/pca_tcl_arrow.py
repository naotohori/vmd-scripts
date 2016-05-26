#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys

def show_usage() :
    print ('')
    print (' Usage: % SCRIPT [template tcl file] [vector file] [(id beginning, id end) ...] [output tcl file]')
    print ('')

if len(sys.argv) < 6 :
    show_usage()
    sys.exit(2)

# Input for ID pairs
id_pairs = []
n = 1
try :
    for arg in sys.argv[3:-1] :
        if n == 1:
            tp = (int(arg),)
        else :
            id_pairs.append(tp + (int(arg),))
        n *= -1
    if n == -1:
        show_usage()
        sys.exit(2)
except :
   show_usage()
   sys.exit(2)
    
# Open files
f_in_tcl = open(sys.argv[1], 'r')
f_in_pca = open(sys.argv[2], 'r')
f_out_tcl = open(sys.argv[-1], 'w')
    
# Read vector data
vectors = []
i_xyz = 0
for line in f_in_pca :
    if line.find('#') != -1 :
        continue
    i_xyz += 1
    if i_xyz == 1:
        vec = (float(line.strip()), )
    elif i_xyz == 2:
        vec += (float(line.strip()), )
    elif i_xyz == 3:
        vec += (float(line.strip()), )
        vectors.append(vec)
        i_xyz = 0
        
# Generate tcl script file
for line_tcl in f_in_tcl :
    
    if line_tcl.find('##SELECTION##') != -1 :
        tcl = ''
        for (i,pair) in enumerate(id_pairs) :
            if i == 0:
                tcl += (' serial %i to %i' % pair)
            else :
                tcl += (' or serial %i to %i' % pair)
        f_out_tcl.write(line_tcl.replace('##SELECTION##', tcl))
        
    elif line_tcl.find('##VECTORS##') != -1 :
        tcl = ''
        for vec in vectors :
            tcl += ' {%f %f %f}' % vec
        f_out_tcl.write(line_tcl.replace('##VECTORS##', tcl))
        
    else :
        f_out_tcl.write(line_tcl)
