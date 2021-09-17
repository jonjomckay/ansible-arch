#!/bin/bash

# Copyright (c) 2021 by Philip Collier, radio AB9IL
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version. There is NO warranty; not even for
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

STREAMS_FILE="$HOME/Music/radiostreams"
OPTION1="Start Internet Radio"
OPTION2="Stop Streaming"
OPTION3="Edit Station List"
OPTIONS="$OPTION1\n$OPTION2\n$OPTION3"
FZF_COMMAND1='fzf --layout=reverse --header=Select:'
ROFI_COMMAND1='rofi -lines 3 -dmenu -p Select'
FZF_COMMAND2='fzf --layout=reverse --header=Select:'
ROFI_COMMAND2='rofi -dmenu -p Select'
FZF_COMMAND3="vim $STREAMS_FILE"
ROFI_COMMAND3="x-terminal-emulator -e vim $STREAMS_FILE"

# interface based on commandline arguments
case "$1" in
    gui)
        COMMAND1=$ROFI_COMMAND1
        COMMAND2=$ROFI_COMMAND2
        COMMAND3=$ROFI_COMMAND3
    ;;
    *)
        COMMAND1=$FZF_COMMAND1
        COMMAND2=$FZF_COMMAND2
        COMMAND3=$FZF_COMMAND3
    ;;
esac

start_player(){
stop_player
sleep 0.5
echo "Connecting to "$CHOICE
mpv --no-video $URL >/dev/null 2>&1 &
exit 0
}

stop_player(){
echo -e "Killing any existing vlc instances..."
killall -9 mpv
}

# select option from first menu
SELECTED="$(echo -e "$OPTIONS" | $COMMAND1 )"

case $SELECTED in
  $OPTION1)
    # read the list of internet audio streams
    readarray STREAMS < $STREAMS_FILE
    # select a stream from the second menu
    CHOICE="$(echo "${STREAMS[@]}" | sed '/^$/d' | awk -F \" '{print $2}' | $COMMAND2 )"
    [[ -z "$CHOICE" ]] && echo "No selection..." && exit 1
    # grep for the correct stream url
    URL="$(echo "${STREAMS[@]}" | grep "${CHOICE}" | awk '{print $1}'| sed 's/^ //g')" && start_player
    ;;
  $OPTION2)
      # cleanly stop the player
      stop_player
    ;;
  $OPTION3)
      # edit the list of streaming stations
      $COMMAND3
    ;;
esac
