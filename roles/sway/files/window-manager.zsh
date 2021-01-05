# Start sway when tty1 starts
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  # Start GNOME Keyring for secrets
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK

  # Start Sway
  exec systemd-cat --identifier=sway sway
fi 