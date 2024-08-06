#!/bin/bash

# Test data generator for Shotwell Tag And Metadata Migrator
#
# Aligns to Shotwell Tag And Metadata Migrator v0.1
#
# This software is provided WITHOUT WARRANTY OF ANY KIND
#
# This is a companion file for ShotwellMetaDataWriter.sh - please read comments in that file
#
# When variable TESTING is set to "-testing" in ShotwellMetaDataWriter.sh expects files ending
# in "-testing", eg 20180905_111235.dng-testing is the test file created for 20180905_111235.dng 
#
# This script creates those files from the image and video files so that testing does not impact live files
#
# This script will need to be aligned to the MY_DATA_POPULATION variable in ShotwellMetaDataWriter.sh so 
# that it creates test files expected by ShotwellMetaDataWriter.sh when in testing mode
#
# Currently this file is aligned to the files expected by ShotwellMetaDataWriter.sh as an illustration of
# how it should be used.  You will need to determine which files within your environment you wish to test that
# script on and then amend both the MY_DATA_POPULATION variable in ShotwellMetaDataWriter.sh and this file to
# reference your chosen test files


# Delete testing files
echo '********************************** DELETING **********************************'

# Delete any existing test files

#RAW
rm /media/Data_Disk/Images/Photos/20180905_111235.jpg-testing
rm /media/Data_Disk/Images/Photos/20180905_111235.dng-testing

rm /media/Data_Disk/Images/Photos/P9035778.ORF-testing
rm /media/Data_Disk/Images/Photos/P9035778.JPG-testing

rm /media/Data_Disk/Images/Photos/IMG_1353.CR3-testing
rm /media/Data_Disk/Images/Photos/IMG_1353.JPG-testing

#JPEG
rm /media/Data_Disk/Images/Photos/001-IMG0032.JPG-testing #Phone
rm /media/Data_Disk/Images/Photos/P3127035.JPG-testing #XZ-1
rm /media/Data_Disk/Images/Photos/PA221630.JPG-testing #PEN
rm /media/Data_Disk/Images/Photos/GOPR9009.JPG-testing #GoPro
rm /media/Data_Disk/Images/Photos/DSC03655.JPG-testing #SONY
rm /media/Data_Disk/Images/Photos/20240616_203805.jpg-testing #Phone
rm /media/Data_Disk/Images/Photos/20240623_110809\(0\).jpg-testing #Phone, odd filename

#VIDEO
rm /media/Data_Disk/Images/Photos/20050821.mp4-testing #MP4
rm /media/Data_Disk/Images/Photos/PC286416.AVI-testing #AVI
rm /media/Data_Disk/Images/Photos/PC286416.AVI-testing.xmp #AVI XMP Sidecar
rm /media/Data_Disk/Images/Photos/PC286416.AVI-testing.exv #AVI EXV Sidecar
rm /media/Data_Disk/Images/Photos/GOPR8576.MP4-testing #GOPro
rm /media/Data_Disk/Images/Photos/GOPR9296.LRV-testing #GoPro LRV
rm /media/Data_Disk/Images/Photos/IMG_9040.MOV-testing #MOV
rm /media/Data_Disk/Images/Photos/Boys\ are\ back\ in\ town\ 2-HD\ \(720p\).m4v-testing #m4v



# Uncomment to stop here if you want to clean up the environment
# exit 1


# Create testing files
echo '********************************** CREATING **********************************'

# Create test files by taking copies of live data files

#RAW
cp /media/Data_Disk/Images/Photos/20180905_111235.jpg /media/Data_Disk/Images/Photos/20180905_111235.jpg-testing
cp /media/Data_Disk/Images/Photos/20180905_111235.dng /media/Data_Disk/Images/Photos/20180905_111235.dng-testing

cp /media/Data_Disk/Images/Photos/P9035778.ORF /media/Data_Disk/Images/Photos/P9035778.ORF-testing
cp /media/Data_Disk/Images/Photos/P9035778.JPG /media/Data_Disk/Images/Photos/P9035778.JPG-testing

cp /media/Data_Disk/Images/Photos/IMG_1353.CR3 /media/Data_Disk/Images/Photos/IMG_1353.CR3-testing
cp /media/Data_Disk/Images/Photos/IMG_1353.JPG /media/Data_Disk/Images/Photos/IMG_1353.JPG-testing

#JPEG
cp /media/Data_Disk/Images/Photos/001-IMG0032.JPG /media/Data_Disk/Images/Photos/001-IMG0032.JPG-testing
cp /media/Data_Disk/Images/Photos/P3127035.JPG /media/Data_Disk/Images/Photos/P3127035.JPG-testing
cp /media/Data_Disk/Images/Photos/PA221630.JPG /media/Data_Disk/Images/Photos/PA221630.JPG-testing
cp /media/Data_Disk/Images/Photos/GOPR9009.JPG /media/Data_Disk/Images/Photos/GOPR9009.JPG-testing
cp /media/Data_Disk/Images/Photos/DSC03655.JPG /media/Data_Disk/Images/Photos/DSC03655.JPG-testing
cp /media/Data_Disk/Images/Photos/20240616_203805.jpg /media/Data_Disk/Images/Photos/20240616_203805.jpg-testing
cp /media/Data_Disk/Images/Photos/20240623_110809\(0\).jpg /media/Data_Disk/Images/Photos/20240623_110809\(0\).jpg-testing

#VIDEO
cp /media/Data_Disk/Images/Photos/20050821.mp4 /media/Data_Disk/Images/Photos/20050821.mp4-testing 
cp /media/Data_Disk/Images/Photos/PC286416.AVI /media/Data_Disk/Images/Photos/PC286416.AVI-testing 
cp /media/Data_Disk/Images/Photos/GOPR8576.MP4 /media/Data_Disk/Images/Photos/GOPR8576.MP4-testing
cp /media/Data_Disk/Images/Photos/GOPR9296.LRV /media/Data_Disk/Images/Photos/GOPR9296.LRV-testing
cp /media/Data_Disk/Images/Photos/IMG_9040.MOV /media/Data_Disk/Images/Photos/IMG_9040.MOV-testing
cp /media/Data_Disk/Images/Photos/Boys\ are\ back\ in\ town\ 2-HD\ \(720p\).m4v /media/Data_Disk/Images/Photos/Boys\ are\ back\ in\ town\ 2-HD\ \(720p\).m4v-testing
