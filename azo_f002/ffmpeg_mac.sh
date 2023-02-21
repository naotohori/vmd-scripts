#!/bin/sh

## This create a good resolution mp4 but cannot be played by QuickTime
#-c:v "libx264"
#-preset "slow"
#-crf 0
#-c:a "copy"
#-pix_fmt "yuv420p"

## This can be played by QuickTime.
#-c:v "h264_videotoolbox"
#-b:v "10M"    <-- Target bitrate to determines the quality and size.
#-c:a "copy"
#-pix_fmt "yuv420p"

# To change the speed
#-vf "setpts=(1/3)*PTS"  <-- This makes the movie 3 times faster.

ffmpeg -r 30 \
       -i "./imagesTIS/movie.%06d.jpg" \
       -c:v "h264_videotoolbox" \
       -b:v "20M" \
       -c:a "copy" \
       -pix_fmt "yuv420p" \
       -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2, setpts=(1/5)*PTS" \
       movieTIS.mp4

ffmpeg -r 30 \
       -i "./imagesMg/movie.%06d.tga" \
       -c:v "h264_videotoolbox" \
       -b:v "20M" \
       -c:a "copy" \
       -pix_fmt "yuv420p" \
       -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2, setpts=(1/5)*PTS" \
       movieMg.mp4

# Put two movies side-by-side.
ffmpeg -i ./movieTIS.mp4 \
       -i ./movieMg.mp4 \
       -filter_complex "[0:v]pad=iw*2:ih[int]; [int][1:v]overlay=W/2:0[vid]" \
       -map "[vid]" \
       -c:v "h264_videotoolbox" \
       -b:v "20M" \
       -c:a "copy" \
       -pix_fmt "yuv420p" \
       ./side-by-side_20M.mp4


# Chagne the play speed afterwards.
#ffmpeg -i side-by-side.mp4 -map 0:v -c:v copy -bsf:v h264_mp4toannexb raw.h264
#ffmpeg -fflags +genpts -r 180 -i raw.h264 -c:v copy side-by-side_x3.mp4
