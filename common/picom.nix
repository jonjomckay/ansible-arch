{ pkgs, ... }:

{
  enable = true;

  activeOpacity = 1;
  inactiveOpacity = 0.8;

  fade = true;
  fadeDelta = 5;
  fadeSteps = [ 0.02 0.02 ];

  opacityRules = [
    "99:class_g = 'Rofi'"
  ];
}
