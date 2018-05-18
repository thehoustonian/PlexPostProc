#!/bin/sh

#******************************************************************************
#******************************************************************************
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#******************************************************************************
#******************************************************************************
#
#  Version: 1.0
#
#  Pre-requisites:
#     HandBrakeCLI
#
#
#  Usage:
#     'PlexPostProc.sh %1'
#
#  Description:
#      My script is currently pretty simple.  Here's the general flow:
#
#      1. Creates a temporary directory in the home directory for
#      the show it is about to transcode.
#
#      2. Uses Handbrake (could be modified to use ffmpeg or other transcoder,
#      but I chose this out of simplicity) to transcode the original, very
#      large MPEG2 format file to a smaller, more manageable H.264 mp4 file
#      (which can be streamed to my Roku boxes).
#
#	   3. Copies the file back to the original filename for final processing
#
#******************************************************************************

#******************************************************************************
#  Do not edit below this line
#******************************************************************************

fatal() {
   echo "[FATAL] $1.";
   echo "[FATAL] Program is now exiting.";
   exit 1;
}
# The above is a simple function for handeling fatal erros. (It outputs an error, and exits the program.)

if [ ! -z "$1" ]; then
# The if selection statement proceeds to the script if $1 is not empty.
   if [ ! -f "$1" ]; then
      fatal "$1 does not exist"
   fi
   # The above if selection statement checks if the file exists before proceeding.

   FILENAME=$1 	# %FILE% - Filename of original file

   TEMPFILENAME="temp_vid_file"  # Temporary File for transcoding

   CURR_DIR=$PWD
   WORKING_DIR=$HOME/PlexPostProc/

   cp $FILENAME $WORKING_DIR

   # Uncomment if you want to adjust the bandwidth for this thread
   #MYPID=$$	# Process ID for current script
   # Adjust niceness of CPU priority for the current process
   #renice 19 $MYPID

   echo "********************************************************"
   echo "Transcoding, Converting to H.264 w/Handbrake"
   echo "********************************************************"
   cd $WORKING_DIR

   HandBrakeCLI -i "$FILENAME" -f av_mp4 --aencoder copy -e x264 --x264-preset medium --x264-profile auto -q 17 --decomb bob -o "$TEMPFILENAME" || fatal "Handbreak has failed (Is it installed?)"

   echo "********************************************************"
   echo "Cleanup / Copy $TEMPFILENAME to $CURR_DIR/$FILENAME"
   echo "********************************************************"
   
   (cd $CURR_DIR && rm -f "$FILENAME")
   rm -f "$FILENAME"
   echo "********************************************************"
   echo "Removed original file"
   echo "********************************************************"
   
   mv -f "$TEMPFILENAME" "${FILENAME%.ts}.mp4"
   # chmod 777 "${FILENAME}.mp4" # This step may no tbe neccessary, but hey why not.
   
   mv -f "${FILENAME%.ts}.mp4" $CURR_DIR
   echo "********************************************************"
   echo "Moved new file to original directory"
   echo "********************************************************"
   echo "Done.  Congrats!"
else
   echo "PlexPostProc by nebhead & thehoustonian"
   echo "Usage: $0 FileName"
fi
