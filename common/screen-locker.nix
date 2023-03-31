{ pkgs, ... }:

{
  enable = true;
  inactiveInterval = 15;
  lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
}
