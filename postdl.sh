#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  - Pn!nkSn@ke - post download script for rtorrent
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [NS] - [07/12/2018] - [1.0 (BETA)]
# -----------------------------------------------------------------------
# DESCRIPTION
#    This program launch filebot tool after each download started in rtorrent
#
# HOW TO
#    Add following line in .rtorrent.rc configuration file
#
# system.method.set_key=event.download.finished,filebot,"execute2={/<path_to_the_script>/postdl.sh,$d.get_base_path=,$d.get_name=}"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TORRENT_PATH="$1"
TORRENT_NAME="$2"

# FileBot Path
#
FILEBOT_PATH="/opt/filebot_portable/filebot.sh"
FILEBOT_OUTPUT="/opt/rtorrent/Media"
FILEBOT_LOG="$DEBUG_DIR/acm.log"

# Export language
#
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

touch "$EXEC_DEBUG"
echo > "$EXEC_DEBUG"
echo "*** New Media added ***";      >> $EXEC_DEBUG
echo "TORRENT_PATH = $TORRENT_PATH"; >> $EXEC_DEBUG
echo "TORRENT_NAME = $TORRENT_NAME"; >> $EXEC_DEBUG

DEBUG_DIR="/opt/rtorrent/log/"

DEBUG_FILE=""
DEBUG_FILE_MOVIES="$DEBUG_DIR/filebot_movies.log"
DEBUG_FILE_SERIES="$DEBUG_DIR/filebot_series.log"
DEBUG_FILE_DEFAULT="$DEBUG_DIR/filebot_default.log"

EXEC_DEBUG="$DEBUG_DIR/postdl.debug"

# not supported yet
#
#DEBUG_FILE_MUSICS="$DEBUG_DIR/filebot_musics.log"
#DEBUG_FILE_ANIMES="$DEBUG_DIR/filebot_animes.log"

IsaMovie=false
IsaSerie=false

function check_movie()
{
    local filename="$1"
    # check many video codec
    #
    case "$1" in 
    *720p* | *1080p* | *x264* | *H264* | *BDRip* | *XviD* )
        IsaMovie=true;
        ;;
    esac
}

function confirm_tvShow()
{
    REGEX="([sS]([0-9]{2,}|[X]{2,})[eE]([0-9]{2,}|[Y]{2,}))"
    if [[ "$1" =~ $REGEX ]]; then
        # MATCH="${BASH_REMATCH[1]}"
        IsaSerie=true;
    fi
}


function check_tvShow()
{ # This function will just search inside the filename pattern S01E01 / s01e01
  #
    local reg='([0-9][0-9]*)[^0-9]*([0-9][0-9]*)'
    local filename="$1"
    local name="${filename%.*}"
    
    if [[ "$name" =~ $reg ]]; then
        printf -v info 'S%02dE%02d' "$((10#${BASH_REMATCH[1]}))" "$((10#${BASH_REMATCH[2]}))"
    fi
    
    # double check
    #
    confirm_tvShow "$name"
}

#### ENTRY POINT ####

# We start with tv show format (S01e01)
#

check_tvShow "$TORRENT_NAME"

if [[ false == "$IsaSerie" ]]; then
    check_movie  "$TORRENT_NAME"
fi


# From this point we know if it's a movie or a TV show
#
echo "Recap: [TV:$IsaSerie | Movie:$IsaMovie]" >> $EXEC_DEBUG

if [[ true == "$IsaSerie" ]]; then
    DATABASE="TheTVDB"
    DATALABEL="TV"
    DEBUG_FILE="$DEBUG_FILE_SERIES"
elif [[ true == "$IsaMovie" ]]; then
    DATABASE="TheMovieDB"
    DATALABEL="Movies"
    DEBUG_FILE="$DEBUG_FILE_MOVIES"
else
    true;
fi

# debug
echo "TORRENT_PATH = $TORRENT_PATH" >> $EXEC_DEBUG
echo "TORRENT_NAME = $TORRENT_NAME" >> $EXEC_DEBUG
echo "DATABASE     = $DATABASE"     >> $EXEC_DEBUG
echo "DATALABEL    = $DATALABEL"    >> $EXEC_DEBUG
echo "DEBUG_FILE   = $DEBUG_FILE"   >> $EXEC_DEBUG

echo "Running filebot ..."          >> $EXEC_DEBUG

if [[ true == "$IsaSerie" || true == "$IsaMovie" ]]; then

    # Clean files
    #
    echo > "$FILEBOT_LOG"
    echo > "$DEBUG_FILE"

    $FILEBOT_PATH --db "$DATABASE" -script fn:amc --output "$FILEBOT_OUTPUT" \
    --action symlink --conflict override -non-strict --def music=y artwork=y \
    --log-file "$FILEBOT_LOG" --log ALL \
    --def "minFileSize=0" "minLenghtMS=0" \
    ut_dir="$TORRENT_PATH" ut_kind="multi" ut_title="$TORRENT_NAME" ut_label="$DATALABEL" & >> $EXEC_DEBUG 2>&1 

else

    $FILEBOT_PATH --encoding utf8 -script fn:amc --output "$FILEBOT_OUTPUT" \
    --action symlink --conflict override -non-strict --def music=y artwork=y \
    --log-file "$FILEBOT_LOG" --log ALL \
    "ut_dir=$TORRENT_PATH" \
    "ut_kind=multi" \
    "minFileSize=0" "minLenghtMS=0" \
    "ut_title=$TORRENT_NAME" \
    "ut_label=$TORRENT_LABEL"  | tee -a "$DEBUG_FILE_DEFAULT" & 
fi

