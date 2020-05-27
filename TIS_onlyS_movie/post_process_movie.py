#!/usr/bin/env python

import subprocess

for l in open('f002_movie_vmd.log'):
    lsp = l.split()
    movieframe = int(lsp[0])
    timeframe = int(lsp[1])

    time = timeframe * 0.00015

    # Convert from dat to tga
    exe = [
    '/usr/local/lib/vmd/tachyon_LINUXAMD64',
    '-V',
    '-trans_vmd',
    'f002.%06d.dat' % movieframe,
    '-o', 'f002.%06d.tga' % movieframe
    ]
    subprocess.call(exe)

    exe = [
    'convert',
    '-font', 'helvetica',
    '-fill', 'black',
    '-pointsize', '36',
    '-draw', 'text 350,450' + " '%4.2f ms'" % time,
    'f002.%06d.tga' % movieframe,
    'f002.%06d.jpg' % movieframe
    ]
    subprocess.call(exe)

exe = [
'ffmpeg',
'-framerate', '60',
'-i', 'f002.%06d.jpg',
'-c:v', 'libx264',
'-preset', 'slow',
'-crf', '0',
'-c:a', 'copy',
'-pix_fmt', 'yuv420p',
'-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2',
'f002.mp4'
]
subprocess.call(exe)
