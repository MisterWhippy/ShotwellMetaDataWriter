# Shotwell Tag And Metadata Migrator

This software is provided WITHOUT WARRANTY OF ANY KIND

Shotwell doesn't write metadata to RAW files, or to the JPEG files associated with those raw files, even
if you select the option "Write tags, titles and other metadata to photo files" in the preferences dialog.
A solution for the JPEGs is apparently to export them all - at which point the tags are attached

Shotwell does write metadata to JPEG files which do not have an associated RAW file if the option
"Write tags, titles and other metadata to photo files" is set.  However, in my time of using Shotwell, it has
sometimes crashed during writing of metadata and so sometimes omitted to write tags to JPEGs

Given this, I wanted a solution to:

   - Write tags from the Shotwell database into RAW files (I have DNG, ORF, CR2 - can't speak for other formats)
   - Write tags from the Shotwell database into the JPEG files associated with RAW files
   - Write tags from the Shotwell database into JPEG files which were 'stand alone' and not associated with RAW files
   - Write tags from the Shotwell database into video files (I have MP4, AVI, LRV, M4V - can't speak for other formats)

This is my solution, build upon a foundation found at https://gist.github.com/iangreenleaf/f6288c6d75103ff28c9145f20539d434

Further comments/documentation can be found in the script files themselves
