#!/bin/bash

# Shotwell Tag And Metadata Migrator
#
# Version: 0.1
#
# This software is provided WITHOUT WARRANTY OF ANY KIND
#
# Shotwell doesn't write metadata to RAW files, or to the JPEG files associated with those raw files, even
# if you select the option "Write tags, titles and other metadata to photo files" in the preferences dialog.
# A solution for the JPEGs is apparently to export them all - at which point the tags are attached
#
# Shotwell does write metadata to JPEG files which do not have an associated RAW file if the option
# "Write tags, titles and other metadata to photo files" is set.  However, in my time of using Shotwell, it has
# sometimes crashed during writing of metadata and so sometimes omitted to write tags to JPEGs
#
# Given this, I wanted a solution to:
#
#   - Write tags from the Shotwell database into RAW files (I have DNG, ORF, CR2 - can't speak for other formats)
#   - Write tags from the Shotwell database into the JPEG files associated with RAW files
#   - Write tags from the Shotwell database into JPEG files which were 'stand alone' and not associated with RAW files
#   - Write tags from the Shotwell database into video files (I have MP4, AVI, LRV, M4V - can't speak for other formats)
#
# This is my solution, build upon a foundation found at https://gist.github.com/iangreenleaf/f6288c6d75103ff28c9145f20539d434
#
# This script extracts data from Shotwell's database (default location: ~/.local/share/shotwell/data/photo.db) and writes 
# it to the image/video files using exiftool.  My focus here has been on tags, but I have left the code for title, comment and
# ratings from the original code written by https://gist.github.com/iangreenleaf/f6288c6d75103ff28c9145f20539d434
#
# Tags are written in alphabetical order into fields TagsList (EXIF), Keywords (IPTC), and Subject (XMP).  For images and videos
# (with the exception of AVI files) these are written directly into the files.  For AVI files, XMP and Exiv2 sidecar files are 
# created in the same directory as the video file, with the same name as the video file
#
# All updates to each file are made at one time in order to try and minimise disk seek times and maximise performance
#
# I have ~30,000 related files and so wanted to be cautious, this code has two switches to facilitate testing.  These 
# switches can be set independently of each other, and there are separate switches for each block of code (RAW, JPEG, Video).
# This provides flexibility and control over testing and running the code
#
#   - TESTING="-testing" / ""
#      - If set to "-testing" a reduced data set is selected by the SQLite query and passed to the rest of the script for action
#         - You can set whatever test population you wish by ammending MY_DATA_POPULATION
#         - In this mode the code expects the string "-testing" at the end of each file, this is to avoid impacting the original files
#         - You can write a simple script to make copies of your test population, appending "-testing" to the file names
#         - eg 20180905_111235.dng-testing is the test file created for 20180905_111235.dng 
#         - See ShotwellMetaDataWriter-ResetTesting.sh as an example script for creating test data (this script is aligned
#           to the SQLite query in this file)
#      - If set to "" (empty string)the full set of live data is selected by SQLite and passed to the rest of the script for action
#   - DRY_RUN="Y" / N"
#      - If set to "Y" additional debugging messages are show, plus no action is taken.  The text of all actions is echo'd to the screen
#      - If set to "N" actions are performed for real, updating all the selected files
#
# Final note, bash is not my native language and so I am sure that there are smarter, squier, more efficient ways to have coded this
#



# Starting....
echo Script Starting!: `date "+%F %T"`



##################################################################################################################
#
#                                               PHOTOS
#
##################################################################################################################



########################################
# Finding tags for RAW files…
########################################
# Set to blank for LIVE, -testing for TESTING
#TESTING="" # Live mode - must be blank to avoid changing flienames
TESTING="-testing" # Testing mode files have this value at the end - ie <my_file_name>.<ext>-testing, eg 20180905_111235.dng-testing
# Set to Y for echo only, N will run the actual commands
DRY_RUN="N"
#DRY_RUN="Y"
RAW_TOTAL=0
if [[ "${TESTING}" == "-testing" ]]; then
   echo "*** TESTING ***"
   echo "Dry Run: ""${DRY_RUN}"
   # Find test files, change LIKE criteria to set the population
   MY_DATA_POPULATION=' where PhotoTable.file_format = 1 and (PhotoTable.filename like "%IMG_1353.CR3" OR PhotoTable.filename like "%20180905_111235.dng" OR PhotoTable.filename like "%P9035778.ORF" )'
else
   echo "************************* LIVE *************************"
   echo "************************* LIVE *************************"
   echo "************************* LIVE *************************"
   echo "Dry Run: ""${DRY_RUN}"
   echo "Dry Run: ""${DRY_RUN}"
   echo "Dry Run: ""${DRY_RUN}"
   read -p "Press <enter>..."
   # Find all RAW files, PhotoTable.file_format=1 identifies raw files
   # (PhotoTable.file_format=2 identifies PNG, PhotoTable.file_format=0 identifies JPEG)
   MY_DATA_POPULATION=' where PhotoTable.file_format = 1'
fi
# Starting....
echo RAW Files Starting!: `date "+%F %T"`
# ORDER BY filename to attempt to reduce disk seek times, ORDER BY tag name to put tags in alphabetical order
MY_QUERY='select replace(PhotoTable.filename, ltrim(PhotoTable.filename, replace(PhotoTable.filename, ".", "")), ""),"."||replace(PhotoTable.filename, rtrim(PhotoTable.filename, replace(PhotoTable.filename, ".", "")), ""), TagTable.name from PhotoTable join TagTable on (TagTable.photo_id_list LIKE printf("%%thumb%016X%%", PhotoTable.id)) '"${MY_DATA_POPULATION}"" ORDER BY PhotoTable.filename, TagTable.name ;"
# Show query in testing modes
if [[ "${TESTING}" == "-testing" || "${DRY_RUN}" == "Y" ]]; then
   echo "${MY_QUERY}"
fi
# This is one long single line statement
# START Statement
sqlite3 ~/.local/share/shotwell/data/photo.db "${MY_QUERY}" \
| ( while IFS="$(printf '\n')" read LINE; \
do IFS='|' read TRUNCATED_PHOTO_FILE PHOTO_EXT TAG_NAME <<< "$LINE"; \
# Test RAW file type, in my environment .dng files have associated .jpg files all my other RAW file types have .JPG
if [[ "${PHOTO_EXT}" == ".dng" ]]; then
   JPEG_FILE_EXT=".jpg"
else
   JPEG_FILE_EXT=".JPG"
fi
if [[ "${DRY_RUN}" == "Y" ]]; then
   # Update RAW File
   # NOTE: CR3 does not support Keywords, code will run but only 2 Tags will be updated
   echo exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${TRUNCATED_PHOTO_FILE}""${PHOTO_EXT}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${TRUNCATED_PHOTO_FILE}${PHOTO_EXT}${TESTING} += '${TAG_NAME}'"
   # Update Associated JPEG
   echo exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${TRUNCATED_PHOTO_FILE}""${JPEG_FILE_EXT}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${TRUNCATED_PHOTO_FILE}${JPEG_FILE_EXT}${TESTING} += '$TAG_NAME'"
else
   # Update RAW File
   # NOTE: CR3 does not support Keywords, code will run but only 2 Tags will be updated
   exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${TRUNCATED_PHOTO_FILE}""${PHOTO_EXT}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${TRUNCATED_PHOTO_FILE}${PHOTO_EXT}${TESTING} += '${TAG_NAME}'"
   # Update Associated JPEG
   exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${TRUNCATED_PHOTO_FILE}""${JPEG_FILE_EXT}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${TRUNCATED_PHOTO_FILE}${JPEG_FILE_EXT}${TESTING} += '$TAG_NAME'"
fi
# Dump changed fields if in a testing mode
# NOTE: CR3 does not support Keywords, so this Tag will not be updated for CR3
if [[ "${TESTING}" == "-testing" || "${DRY_RUN}" == "Y" ]]; then
   exiftool -G1 -a -s "${TRUNCATED_PHOTO_FILE}""${PHOTO_EXT}""${TESTING}" | grep -i 'FileName\|Keyword\|Subject\|Tags'
   exiftool -G1 -a -s "${TRUNCATED_PHOTO_FILE}""${JPEG_FILE_EXT}""${TESTING}" | grep -i 'FileName\|Keyword\|Subject\|Tags'
fi
RAW_TOTAL=$((RAW_TOTAL+1))
done && echo "Done updating Tags for RAW files! ""$RAW_TOTAL"" updates made" ) # Must put the echo here, as otherwise variable not seen
# Finished....
echo RAW files Finished!: `date "+%F %T"`



########################################
# Finding tags for JPEG files…
########################################
# Set to blank for LIVE, -testing for TESTING
#TESTING="" # Live mode - must be blank to avoid changing flienames
TESTING="-testing" # Testing mode files have this value at the end - ie <my_file_name>.<ext>-testing, eg 20180905_111235.jpg-testing
# Set to Y for echo only, N will run the actual commands
DRY_RUN="N"
#DRY_RUN="Y"
JPEG_TOTAL=0
if [[ "${TESTING}" == "-testing" ]]; then
   echo "*** TESTING ***"
   echo "Dry Run: ""${DRY_RUN}"
   # Find test files, change LIKE criteria to set the population
   MY_DATA_POPULATION=' WHERE PhotoTable.file_format = 0 and (PhotoTable.filename like "%001-IMG0032.JPG" or PhotoTable.filename like "%P3127035.JPG" OR PhotoTable.filename like "%PA221630.JPG" OR PhotoTable.filename like "%GOPR9009.JPG" OR PhotoTable.filename like "%DSC03655.JPG" OR PhotoTable.filename like "%20240616_203805.jpg" OR PhotoTable.filename like "%20240623_110809(0).jpg") '
else
   echo "************************* LIVE *************************"
   echo "************************* LIVE *************************"
   echo "************************* LIVE *************************"
   echo "Dry Run: ""${DRY_RUN}"
   echo "Dry Run: ""${DRY_RUN}"
   echo "Dry Run: ""${DRY_RUN}"
   read -p "Press <enter>..."
   # Find all JPEG files, PhotoTable.file_format=1 identifies raw files
   # (PhotoTable.file_format=2 identifies PNG, PhotoTable.file_format=0 identifies JPEG)
   MY_DATA_POPULATION=' where PhotoTable.file_format = 0'
fi
# Starting....
echo JPEG Files Starting!: `date "+%F %T"`
# ORDER BY filename to attempt to reduce disk seek times, ORDER BY tag name to put tags in alphabetical order
MY_QUERY='select PhotoTable.filename, TagTable.name from PhotoTable join TagTable on (TagTable.photo_id_list LIKE printf("%%thumb%016X%%", PhotoTable.id)) '"${MY_DATA_POPULATION}"" ORDER BY PhotoTable.filename, TagTable.name;"
# Show query in testing modes
if [[ "${TESTING}" == "-testing" || "${DRY_RUN}" == "Y" ]]; then
   echo "${MY_QUERY}"
fi
# This is one long single line statement
# START Statement
sqlite3 ~/.local/share/shotwell/data/photo.db "${MY_QUERY}" \
| ( while IFS="$(printf '\n')" read LINE; \
do IFS='|' read PHOTO_FILE TAG_NAME <<< "$LINE"; \
if [[ "${DRY_RUN}" == "Y" ]]; then
   # Update JPEG File
   echo exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${PHOTO_FILE}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${PHOTO_FILE}${TESTING} += '${TAG_NAME}'"
else
   # Update JPEG File
   exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${PHOTO_FILE}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${PHOTO_FILE}${TESTING} += '${TAG_NAME}'"
fi
# Dump changed fields if in a testing mode
if [[ "${TESTING}" == "-testing" || "${DRY_RUN}" == "Y" ]]; then
   exiftool -G1 -a -s "${PHOTO_FILE}""${TESTING}" | grep -i 'FileName\|Keyword\|Subject\|Tags'
fi
JPEG_TOTAL=$((JPEG_TOTAL+1))
done && echo "Done updating Tags for JPEG files! ""$JPEG_TOTAL"" updates made" ) # Must put the echo here, as otherwise variable not seen
# Finished....
echo JPEG Files Finished!: `date "+%F %T"`


########################################
# Finding rating for photo files
# NOTE: Not relevant to my use case
########################################
#sqlite3 ~/.local/share/shotwell/data/photo.db 'select filename, rating from PhotoTable where rating > 0 and file_format = 1;' | while IFS="$(printf '\n')" read LINE; do IFS='|' read PHOTO_FILE RATING <<< "$LINE"; exiftool -Rating="$RATING" "$PHOTO_FILE" || echo "Trouble! $PHOTO_FILE = $Rating stars"; done
#echo "Done updating Ratings for RAW files!"

########################################
# Finding titles and comments for photos files
# NOTE: Not relevant to my use case
########################################
#sqlite3 ~/.local/share/shotwell/data/photo.db 'select filename, title, comment from PhotoTable where (title is not null or comment is not null) and file_format = 1;' | while IFS="$(printf '\n')" read LINE; do IFS='|' read PHOTO_FILE TITLE COMMENT <<< "$LINE"; exiftool -Title="$TITLE" -Headline="$TITLE" -UserComment="$COMMENT" -Description="$COMMENT" "$PHOTO_FILE" || echo "Trouble! $PHOTO_FILE title/comments"; done
#echo "Done updating Title & Comments for RAW files!"



##################################################################################################################
#
#                                               VIDEOS
#
##################################################################################################################


########################################
# Finding tags for Video files…
########################################
# Set to blank for LIVE, -testing for TESTING
#TESTING="" # Live mode - must be blank to avoid changing flienames
TESTING="-testing" # Testing mode files have this value at the end - ie <my_file_name>.<ext>-testing, eg 20180905_111235.mp4-testing
# Set to Y for echo only, N will run the actual commands
DRY_RUN="N"
#DRY_RUN="Y"
VIDEO_TOTAL=0
if [[ "${TESTING}" == "-testing" ]]; then
   echo "*** TESTING ***"
   echo "Dry Run: ""${DRY_RUN}"
   # Find test files, change LIKE criteria to set the population
   MY_DATA_POPULATION=' WHERE (VideoTable.filename like "%20050821.mp4" or VideoTable.filename like "%PC286416.AVI" OR VideoTable.filename like "%/GOPR8576.MP4" OR VideoTable.filename like "%/GOPR9296.LRV" OR VideoTable.filename like "%/IMG_9040.MOV" OR VideoTable.filename like "%/Boys are back in town 2-HD (720p).m4v") '
else
   echo "************************* LIVE *************************"
   echo "************************* LIVE *************************"
   echo "************************* LIVE *************************"
   echo "Dry Run: ""${DRY_RUN}"
   echo "Dry Run: ""${DRY_RUN}"
   echo "Dry Run: ""${DRY_RUN}"
   read -p "Press <enter>..."
   # Find all video files
   MY_DATA_POPULATION=' ' # We want all the videos
fi
# Starting....
echo Videos Starting!: `date "+%F %T"`
# ORDER BY filename to attempt to reduce disk seek times, ORDER BY tag name to put tags in alphabetical order
MY_QUERY='select VideoTable.filename, TagTable.name from VideoTable join TagTable on (TagTable.photo_id_list LIKE printf("%%video-%016X%%", VideoTable.id)) '"${MY_DATA_POPULATION}"" ORDER BY VideoTable.filename, TagTable.name ;"
# Show query in testing modes
if [[ "${TESTING}" == "-testing" || "${DRY_RUN}" == "Y" ]]; then
   echo "${MY_QUERY}"
fi
# This is one long single line statement
# START Statement
sqlite3 ~/.local/share/shotwell/data/photo.db "${MY_QUERY}" \
| ( while IFS="$(printf '\n')" read LINE; \
do IFS='|' read VIDEO_FILE TAG_NAME <<< "$LINE"; \
# Get file extension
FILE_EXT="${VIDEO_FILE##*\.}" # Everything after the last '.'
FILE_EXT=${FILE_EXT^^} # Convert to uppercase
if [[ "${DRY_RUN}" == "Y" ]]; then
   # For AVI files, special treatment is needed as EXIF tags cannot be written to AVI
   # So we will create sidecar files - two formats for hopeful forward compatibility
   if [[ "${FILE_EXT}" == "AVI" ]]; then
      for SIDECAR_TYPE in ".xmp" ".exv"
      do
         if [ ! -f "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" ]; then
            echo "Sidecar does not exist: ""${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}"
            # Create sidecar
            echo exiftool -tagsfromfile "${VIDEO_FILE}""${TESTING}" "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" > /dev/null 2> /dev/null || echo "Trouble! ${VIDEO_FILE}${TESTING}{SIDECAR_TYPE}"
         fi
         # Write tags to sidecar
         echo exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" > /dev/null 2> /dev/null || echo "Trouble! ${VIDEO_FILE}${TESTING}${SIDECAR_TYPE} += '${TAG_NAME}'"
      done
   else # Not AVI
      # Update Video File
      echo exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${VIDEO_FILE}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${VIDEO_FILE}${TESTING} += '${TAG_NAME}'"
   fi
else # Not Dry Run
   # For AVI files, special treatment is needed as EXIF tags cannot be written to AVI
   # So we will create sidecar files - two formats for hopeful forward compatibility
   if [[ "${FILE_EXT}" == "AVI" ]]; then
      for SIDECAR_TYPE in ".xmp" ".exv"
      do
         if [ ! -f "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" ]; then
            # Create sidecar
            exiftool -tagsfromfile "${VIDEO_FILE}""${TESTING}" "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" > /dev/null 2> /dev/null || echo "Trouble! ${VIDEO_FILE}${TESTING}{SIDECAR_TYPE}"
         fi
         # Write tags to sidecar - not all tags are written to xmp
         exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" > /dev/null 2> /dev/null || echo "Trouble! ${VIDEO_FILE}${TESTING}${SIDECAR_TYPE} += '${TAG_NAME}'"
      done
   else # Not AVI
      # Update Video File
      exiftool -overwrite_original_in_place -preserve -IPTC:Keywords-="${TAG_NAME}" -IPTC:Keywords+="${TAG_NAME}" -XMP:Subject-="${TAG_NAME}" -XMP:Subject+="${TAG_NAME}" -TagsList-="${TAG_NAME}" -TagsList+="${TAG_NAME}" "${VIDEO_FILE}""${TESTING}" > /dev/null 2> /dev/null || echo "Trouble! ${VIDEO_FILE}${TESTING} += '${TAG_NAME}'"
   fi
fi # Run type
# Dump changed fields if in a testing mode
if [[ "${TESTING}" == "-testing" || "${DRY_RUN}" == "Y" ]]; then
   if [[ "${FILE_EXT}" == "AVI" ]]; then
      for SIDECAR_TYPE in ".xmp" ".exv"
      do
         echo "Sidecar type: ""${SIDECAR_TYPE}"
         exiftool -G1 -a -s "${VIDEO_FILE}""${TESTING}""${SIDECAR_TYPE}" | grep -i 'FileName\|Keyword\|Subject\|Tags'
      done
   else
      exiftool -G1 -a -s "${VIDEO_FILE}""${TESTING}" | grep -i 'FileName\|Keyword\|Subject\|Tags'
   fi
fi
VIDEO_TOTAL=$((VIDEO_TOTAL+1))
done && echo "Done updating Tags for VIDEO files! ""$VIDEO_TOTAL"" updates made" ) # Must put the echo here, as otherwise variable not seen
# Finished....
echo Videos Finished!: `date "+%F %T"`



# Finished....
echo Script Finished!: `date "+%F %T"`


