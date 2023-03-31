{ pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    comic-mono
    dejavu_fonts
    fira-code
    fira-code-symbols
    fira-mono
    font-awesome
    ipafont
    liberation_ttf
    noto-fonts-cjk
    noto-fonts-emoji
  ];
}