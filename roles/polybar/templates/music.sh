#!/bin/bash

player_status=$(playerctl status 2> /dev/null)
if [[ $? -eq 0 ]]; then
   artist=$(playerctl -s metadata artist)
   title=$(playerctl -s metadata title)

   if [[ $artist = '' ]]; then
     metadata=$title
   else
     metadata="$artist - $title"

     starter=" - $"
     if [[ $metadata =~ $starter ]]; then
       metadata="$(playerctl metadata album) - $(playerctl metadata title)"
     fi
   fi
fi

url=$(playerctl -s metadata xesam:url)

if [[ $url = http* ]]; then
  icon="📻"
else
  icon="🎧"
fi

# Foreground color formatting tags are optional
if [[ $player_status = "Playing" ]]; then
    echo "$icon %{F#FFFFFF}$metadata%{F-}"
elif [[ $player_status = "Paused" ]]; then
    echo "$icon %{F#999}$metadata%{F-}"
else
    echo ""
fi
