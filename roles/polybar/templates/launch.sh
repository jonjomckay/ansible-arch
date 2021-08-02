#!/bin/sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

MONITORS=($(polybar --list-monitors | cut -d":" -f1))

# Launch Polybar
for i in "${!MONITORS[@]}"; do
    MONITOR="${MONITORS[$i]}" polybar --reload --config=~/.config/polybar/config.${i}.ini mybar &
done

echo "Polybar launched..."
