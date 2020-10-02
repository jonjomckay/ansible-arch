# Start sway when tty1 starts
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  _JAVA_AWT_WM_NONREPARENTING=1 exec systemd-cat --identifier=sway sway
fi