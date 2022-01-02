#!/bin/sh

## This create a good resolution mp4 but cannot be played by QuickTime
#-c:v "libx264"
#-preset "slow"
#-crf 0
#-c:a "copy"
#-pix_fmt "yuv420p"

## This can be played by QuickTime.
#-c:v "h264_videotoolbox"
#-b:v "10000k"
#-c:a "copy"
#-pix_fmt "yuv420p"

ffmpeg -framerate 60 \
       -i "./imagesTIS/movie.%06d.jpg" \
       -c:v "h264_videotoolbox" \
       -b:v "10000k" \
       -c:a "copy" \
       -pix_fmt "yuv420p" \
       -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
       movieTIS.mp4

ffmpeg -framerate 60 \
       -i "./imagesMg/movie.%06d.tga" \
       -c:v "h264_videotoolbox" \
       -b:v "10000k" \
       -c:a "copy" \
       -pix_fmt "yuv420p" \
       -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
       movieMg.mp4

ffmpeg -i ./movieTIS.mp4 \
       -i ./movieMg.mp4 \
       -filter_complex "[0:v]pad=iw*2:ih[int]; [int][1:v]overlay=W/2:0[vid]" \
       -map "[vid]" \
       -c:v "h264_videotoolbox" \
       -b:v "10000k" \
       -c:a "copy" \
       -pix_fmt "yuv420p" \
       ./side-by-side.mp4
