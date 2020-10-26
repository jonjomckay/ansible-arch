# Start sway when tty1 starts
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec systemd-cat --identifier=sway sway
fi 