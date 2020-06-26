#!/usr/bin/env python

import subprocess

projectname = 'sample'
PATH_TACHYON = '/usr/local/lib/vmd/tachyon_LINUXAMD64'

for l in open('%s_movie_vmd.log' % projectname):
    lsp = l.split()
    movieframe = int(lsp[0])
    timeframe = int(lsp[1])

    time = timeframe * 0.00015

    # Convert from dat to tga
    exe = [
    PATH_TACHYON,
    '-V',
    '-trans_vmd',
    '%s.%06d.dat' % (projectname, movieframe),
    '-o', '%s.%06d.tga' % (projectname, movieframe)
    ]
    subprocess.call(exe)

    exe = [
    'convert',
    '-font', 'helvetica',
    '-fill', 'black',
    '-pointsize', '36',
    '-draw', 'text 350,450' + " '%4.2f ms'" % time,
    '%s.%06d.tga' % (projectname, movieframe),
    '%s.%06d.jpg' % (projectname, movieframe)
    ]
    subprocess.call(exe)

exe = [
'ffmpeg',
'-framerate', '60',
'-i', projectname + '.%06d.jpg',
'-c:v', 'libx264',
'-preset', 'slow',
'-crf', '0',
'-c:a', 'copy',
'-pix_fmt', 'yuv420p',
'-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2',
'%s.mp4' % projectname
]
subprocess.call(exe)
