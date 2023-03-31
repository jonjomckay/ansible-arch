{ pkgs, ... }:

{
  enable = true;

  enableAutosuggestions = true;
  enableCompletion = true;

  history = {
    ignoreDups = true;
    ignoreSpace = true;
    save = 100000;
    share = true;
    size = 100000;
  };

  oh-my-zsh = {
    enable = true;

    extraConfig = ''
      # Enable automatic updates
      zstyle ':omz:update' mode auto
    '';
  };

  shellAliases = {
    "c" = "xclip -selection clipboard -i";
    "cat" = "bat -pp";
  };
}
