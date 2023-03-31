{ pkgs, ... }:

{
  enable = true;

  package = pkgs.vscodium;

  userSettings = {
    "debug.console.fontSize" = 12;
    "editor.fontFamily" = "'Fira Code'";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 12;
    "editor.fontWeight" = "450";
    "editor.minimap.enabled" = false;
    "markdown.preview.fontSize" = 12;
    "terminal.integrated.fontSize" = 12;
  };
}
