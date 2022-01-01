#!/usr/bin/env python

import subprocess

logfile = 'f002.origin.TIS.vmd.log'
PATH_TACHYON = '/Users/hori/local/tachyon/compile/macosx-x86-thr/tachyon'

for l in open(logfile):
    lsp = l.split()
    movieframe = int(lsp[0])
    timeframe = int(lsp[1])

    time = timeframe * 0.00015

#    ### TIS
#    # Convert from dat to tga
#    exe = [
#    PATH_TACHYON,
#    #'-V',
#    #'-trans_vmd',
#    '-aasamples', '12',
#    '-format', 'TARGA',
#    '-res', '4000 4000'
#    'imagesTIS/movie.%06d.dat' % (movieframe,),
#    '-o', 'imagesTIS/movie.%06d.tga' % (movieframe,)
#    ]
#    subprocess.call(exe)

    exe = [
    'convert',
    '-font', 'helvetica',
    '-fill', 'black',
    #'-draw', 'text 350,450' + " '%4.2f ms'" % time,
    ### For 650 x 650
    #'-pointsize', '36',
    #'-draw', 'text 500,600' + " '%4.2f ms'" % time,
    '-pointsize', '45',
    '-draw', 'text 800,950' + " '%4.2f ms'" % time,
    'imagesTIS/movie.%06d.tga' % (movieframe,),
    'imagesTIS/movie.%06d.jpg' % (movieframe,)
    ]
    subprocess.call(exe)

#    ### Mg
#    # Convert from dat to tga
#    exe = [
#    PATH_TACHYON,
#    #'-V',
#    #'-trans_vmd',
#    '-aasamples', '12',
#    '-format', 'TARGA',
#    '-res', '4000 4000'
#    'imagesMg/movie.%06d.dat' % (movieframe,),
#    '-o', 'imagesMg/movie.%06d.tga' % (movieframe,)
#    ]
#    subprocess.call(exe)

