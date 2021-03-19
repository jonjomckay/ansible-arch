# Start sway when tty1 starts
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  # Start Sway
  exec systemd-cat --identifier=sway sway
fi 