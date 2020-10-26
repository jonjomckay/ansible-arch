# Start sway when tty1 starts
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK

  exec systemd-cat --identifier=sway sway
fi 