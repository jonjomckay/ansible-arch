{ pkgs, config, ... }:

{
  enable = true;
  package = pkgs.firefox-devedition-bin;
}