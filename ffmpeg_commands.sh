# Compress mp4
# CRF should be 0-51. Default is 23. 0 is the best quality, 51 is worst.
ffmpeg -i input.mp4 -vcodec libx265 -crf 28 output.mp4
