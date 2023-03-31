{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>

      ../common/audio.nix
      ../common/fonts.nix
      ../common/system.nix
    ];

  hardware.bluetooth.enable = true;

  networking.hostName = "dennis";
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Required for NetworkManager to save connections
  programs.dconf.enable = true;

  services.blueman.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    deviceSection = ''
      Option "TearFree" "true"
    '';

    displayManager = {
      defaultSession = "none+i3";

      autoLogin = {
        enable = true;
        user = "jonjo";
      };
    };

    videoDrivers = [ "amdgpu" ];

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };

  services.xserver.libinput.enable = true;

  users.users.jonjo = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      androidStudioPackages.beta
      aria2
      bat
      bind
      bitwarden
      bmon
      brightnessctl
      dex
      htop
      inetutils
      iotop
      jetbrains.pycharm-professional
      jq
      mpdris2
      networkmanagerapplet
      nixpkgs-fmt
      pavucontrol
      playerctl
      rsync
      whois
    ];

    shell = pkgs.zsh;

    openssh = {
      authorizedKeys = {
        keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/rFBmqQS57lzIKSxNq7eE45X/hKuKbez+5b3c14wwQJPd0L24Vt/Ty0F5luyzTpxO6xxubL/isQgopQnkDYKEb6yznkoEqLVLiYd9wNfBO/22KxUiSxmrsfM4eo2cO+P4BTjYsRksTizpgm4kywnTK+3M1bxQ0pIx+AQqq5/LsE3gF7RsdKUW5b/JAiXimUg4B4dk2bRGzRmRrbmk8otuaOVMHMLpEYVDejPQvuSKVsUcMo8TFNNnIcBhjxrmml0DuBf4JJV5mIV2RXfWQsgDTuWHnSsX27B75dCPh0fDM1jhprY1E7M2Prl5QfcnXVKZPWI27glrtzzSLJw/cYJF"
        ];
      };
    };
  };

  home-manager.users.jonjo = { pkgs, config, ... }: {
    home.stateVersion = "22.11";

    fonts.fontconfig.enable = true;

    gtk = (import ../common/gtk.nix pkgs);

    programs.alacritty = (import ../common/alacritty.nix pkgs);
    programs.feh.enable = true;
    programs.firefox = (import ../common/firefox.nix pkgs);
    programs.git = (import ../common/git.nix pkgs);
    programs.rofi = {
      enable = true;

      font = "Fira Code 11";
      location = "center";

      extraConfig = {
        modi = "window,run,ssh,drun";
        show-icons = true;
        xoffset = 0;
        yoffset = 0;
      };

      theme =
        let inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            background-color = mkLiteral "#282C33";
            border-color = mkLiteral "#2e343f";
            text-color = mkLiteral "#8ca0aa";
            spacing = 0;
            width = 512;
          };

          "window" = {
            border = 3;
            border-color = mkLiteral "#ed6d9f";
            border-radius = 3;
          };

          "inputbar" = {
            border = mkLiteral "0 0 1px 0";
            children = mkLiteral "[prompt,entry]";
          };

          "prompt" = {
            padding = 16;
            border = mkLiteral "0 0 1px";
          };

          "textbox" = {
            background-color = mkLiteral "#2e343f";
            border = mkLiteral "0 0 1px 0";
            border-color = mkLiteral "#282C33";
            padding = "8px 16px";
          };

          "entry" = {
            padding = 16;
            vertical-align = 1;
          };

          "listview" = {
            cycle = false;
            margin = mkLiteral "0 0 -1px 0";
            scrollbar = false;
          };

          "element" = {
            border = mkLiteral "0 0 1px 0";
            padding = 16;
          };

          "element selected" = {
            background-color = mkLiteral "#2e343f";
          };

          "element-icon" = {
            margin = mkLiteral "0 8px 0 0";
            size = mkLiteral "2ch";
          };
        };
    };
    programs.ssh = (import ../common/ssh.nix pkgs);
    programs.starship = (import ../common/starship.nix pkgs);
    programs.vscode = (import ../common/vscode.nix pkgs);
    programs.zsh = (import ../common/zsh.nix pkgs);

    services.blueman-applet.enable = true;
    services.dunst = (import ../common/dunst.nix pkgs);
    services.gnome-keyring = (import ../common/gnome-keyring.nix pkgs);
    services.mpris-proxy.enable = true;
    services.picom = (import ../common/picom.nix pkgs);
    services.polybar = (import ../common/polybar.nix pkgs);
    services.redshift = (import ../common/redshift.nix pkgs);
    services.screen-locker = (import ../common/screen-locker.nix pkgs);

    xsession.windowManager.i3 = (import ../common/i3.nix pkgs);
  };

  services.tlp.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

