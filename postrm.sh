#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  - Pn!nkSn@ke - post delete script for rtorrent
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [NS] - [07/12/2018] - [1.0 (BETA)]
# -----------------------------------------------------------------------
# DESCRIPTION
#    This program launch filebot tool after each delete in rtorrent
#
# HOW TO
# 	 Add following line in .rtorrent.rc configuration file
#
# method.set_key = event.download.erased,filebot_cleaner,"execute2=/<path_to_the_script>/postrm.sh"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FILEBOT_PATH="/opt/filebot_portable/filebot.sh"

MYLOCKDIR="/tmp/lockdir/"
MYLOCKFILE="/tmp/lockdir/cleaner.lock"
FILEBOT_OUTPUT="/opt/rtorrent/Media"

LOGFILE="/opt/rtorrent/log/postrm.log"

# Clean log file first - keep only last entry -
#
touch "$LOGFILE"
echo > "$LOGFILE"

# Create the Locking dir if it doesn't exist
#
if [[ ! -d "$MYLOCKDIR" ]]; then
    mkdir -p $MYLOCKDIR
fi

# Check if there is currently a lock in place, if so then exit, if not then create a lock
#
if [ -f "$MYLOCKFILE" ]; then
    echo "Cleaner is currently already running. Abort!"
    exit 1
else
    touch "$MYLOCKFILE"
fi

# Do some stuff
#
echo "Cleaner will start his job after sleep 10sec..."

# Sleep is needed because of deleting file can take a while
# and we don't need to do the job fast :-)
#
sleep 10;

# We search all broken symbolic link and delete it
#
find $FILEBOT_OUTPUT -type l | while read in; do
    file "$in" | grep "broken symbolic link"
    if [ $? -ne 1 ]; then
        echo -n "Deleting $in... " >> "$LOGFILE"
        rm -f "$in"
        echo "Done." >> "$LOGFILE"
    fi
done

# call filbot to clean empty folders
#

$FILEBOT_PATH -script fn:cleaner $FILEBOT_OUTPUT

# Release the lock
#
rm -rf "$MYLOCKDIR"
echo "The lock is now released." >> "$LOGFILE"
