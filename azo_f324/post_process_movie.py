#!/usr/bin/env python

import subprocess

logfile = 'f324.TIS.vmd.log'
#PATH_TACHYON = '/Users/hori/local/tachyon/compile/macosx-x86-thr/tachyon'

for l in open(logfile):
    lsp = l.split()
    movieframe = int(lsp[0])
    timeframe = int(lsp[1])

    time = timeframe * 0.00015

    if timeframe == 200001:
        time = 30.00

#    ### TIS
#    # Convert from dat to tga
#    exe = [
#    PATH_TACHYON,
#    #'-V',
#    #'-trans_vmd',
#    '-aasamples', '12',
#    '-format', 'TARGA',
#    '-res', '4000', '4000'
#    'imagesTIS/movie.%06d.dat' % (movieframe,),
#    '-o', 'imagesTIS/movie.%06d.tga' % (movieframe,)
#    ]
#    subprocess.call(exe)
#
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
    ]

    #if not 1334 <= timeframe <= 8420:
    #    continue
    #if timeframe != 200001:
    #    continue


    if 1200 <= timeframe <= 1300:
        exe.extend(['./caption_P7.png',
                    'imagesTIS/movie.%06d.tga' % (movieframe,),
                    '-compose', 'dstover', '-composite'])

    elif 6100 <= timeframe <= 6400:
        exe.extend(['./caption_TL9-TR5_1.png',
                    'imagesTIS/movie.%06d.tga' % (movieframe,),
                    '-compose', 'dstover', '-composite'])

    elif 8400 <= timeframe <= 8700:
        exe.extend(['./caption_TL2-TR8.png',
                    'imagesTIS/movie.%06d.tga' % (movieframe,),
                    '-compose', 'dstover', '-composite'])

    elif 67000 <= timeframe <= 67350:
        exe.extend(['./caption_SE_P3.png',
                    'imagesTIS/movie.%06d.tga' % (movieframe,),
                    '-compose', 'dstover', '-composite'])

    elif 72300 <= timeframe <= 72600:
        exe.extend(['./caption_TL9-TR5_2.png',
                    'imagesTIS/movie.%06d.tga' % (movieframe,),
                    '-compose', 'dstover', '-composite'])

    elif 107500 <= timeframe <= 107800:
        exe.extend(['./caption_TL9-TR5_3.png',
                    'imagesTIS/movie.%06d.tga' % (movieframe,),
                    '-compose', 'dstover', '-composite'])

    else:
        exe.append('imagesTIS/movie.%06d.tga' % (movieframe,))

    exe.append('imagesTIS/movie.%06d.jpg' % (movieframe,))
    subprocess.call(exe)

#    ### Mg
#    # Convert from dat to tga
#    exe = [
#    PATH_TACHYON,
#    #'-V',
#    #'-trans_vmd',
#    '-aasamples', '12',
#    '-format', 'TARGA',
#    '-res', '4000', '4000'
#    'imagesMg/movie.%06d.dat' % (movieframe,),
#    '-o', 'imagesMg/movie.%06d.tga' % (movieframe,)
#    ]
#    subprocess.call(exe)

