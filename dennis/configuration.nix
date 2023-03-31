# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  polybarBluetoothPythonPackages = ps: with ps; [ dbus-python ];
  polybarBluetoothPython = pkgs.python3.withPackages polybarBluetoothPythonPackages;
  polybarBluetooth = pkgs.writeScript "polybar-bluetooth.py" ''
    #!${polybarBluetoothPython}/bin/python3
    import dbus

    try:
      bus = dbus.SystemBus()
      device = bus.get_object('org.bluez', '/org/bluez/hci0/dev_38_18_4C_06_73_70')
      iface = dbus.Interface(device, 'org.freedesktop.DBus.Properties')
      battery_level = int(iface.Get('org.bluez.Battery1', 'Percentage'))

      print(f'🎧 {battery_level}%')
    except:
      pass
  '';
  polybarMusic = pkgs.writeShellScriptBin "polybar-music.sh" ''
    PLAYERCTL="${pkgs.playerctl}/bin/playerctl"

    player_status=$($PLAYERCTL status 2> /dev/null)
    if [[ $? -eq 0 ]]; then
      artist=$($PLAYERCTL -s metadata artist)
      title=$($PLAYERCTL -s metadata title)

      if [[ $artist = "" ]]; then
        metadata=$title
      else
        metadata="$artist - $title"

        starter=" - $"
        if [[ $metadata =~ $starter ]]; then
          metadata="$($PLAYERCTL metadata album) - $($PLAYERCTL metadata title)"
        fi
      fi
    fi

    url=$($PLAYERCTL -s metadata xesam:url)

    if [[ $url = http* ]]; then
      icon="📻"
    else
      icon="🎧"
    fi

    # Foreground color formatting tags are optional
    if [[ $player_status = "Playing" ]]; then
        echo "$icon %{F#FFFFFF}$metadata%{F-}"
    elif [[ $player_status = "Paused" ]]; then
        echo "$icon %{F#999}$metadata%{F-}"
    else
        echo ""
    fi
  '';

in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;

  networking.hostName = "dennis";
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Required for NetworkManager to save connections
  programs.dconf.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  services.blueman.enable = true;

  services.timesyncd.enable = true;

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
      extraPackages = with pkgs; [
        dmenu
        i3lock
      ];
    };
  };

  programs.zsh = {
    enable = true;
  };

  # Configure keymap in X11
  # services.xserver.layout = "uk";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;

  environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
    bluez_monitor.properties = {
      ["bluez5.enable-sbc-xq"] = true,
      ["bluez5.enable-msbc"] = true,
      ["bluez5.enable-hw-volume"] = true,
      ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    }
  '';

  services.pipewire = {
    enable = true;

    pulse = {
      enable = true;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jonjo = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
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
      polybarMusic
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

  home-manager.users.jonjo = { pkgs, config, ... }: {
    home.stateVersion = "22.11";

    fonts.fontconfig.enable = true;

    gtk = {
      enable = true;

      gtk2.extraConfig = ''
        gtk-application-prefer-dark-theme = "true"
      '';

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    programs.alacritty.enable = true;
    programs.alacritty.settings = {
      colors = {
        bright = {
          black = "#969896";
          blue = "#2b7bf1";
          cyan = "#58cbf9";
          green = "#74faa9";
          magenta = "#e23df0";
          red = "#ee7bca";
          white = "#ffffff";
          yellow = "#fffaa3";
        };

        cursor = {
          cursor = "#c5c8c6";
        };

        normal = {
          black = "#1d1f21";
          blue = "#3592f4";
          cyan = "#67d5fa";
          green = "#82f8b8";
          magenta = "#ea60f3";
          red = "#f393d4";
          white = "#c5c8c6";
          yellow = "#fff9b2";
        };

        primary = {
          background = "#1d1f21";
          foreground = "#c5c8c6";
        };
      };

      env = {
        TERM = "xterm-256color";
      };

      font = {
        normal = {
          family = "Fira Mono";
          weight = 450;
        };
        size = 5.5;
      };

      scrolling = {
        history = 100000;
      };

      window.padding = {
        x = 10;
        y = 10;
      };
    };

    programs.feh.enable = true;

    programs.firefox = {
      enable = true;

      package = pkgs.firefox-devedition-bin;
    };

    programs.git = {
      enable = true;

      signing = {
        key = "C4CC649D7F58611D";
        signByDefault = true;
      };

      userEmail = "jonjo@jonjomckay.com";
      userName = "Jonjo McKay";
    };

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

    programs.ssh = {
      enable = true;
      compression = true;
    };

    programs.starship = {
      enable = true;

      enableZshIntegration = true;
    };

    programs.zsh = {
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
    };

    programs.vscode = {
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
    };

    services.blueman-applet.enable = true;

    services.dunst = {
      enable = true;

      settings = {
        global = {
          alignment = "center";
          follow = "mouse";
          format = ''<b>%s</b>
          %b'';
          frame_color = "#8EC07C";
          frame_width = 3;
          geometry = "300x50-15+49";
          horizontal_padding = 6;
          line_height = 3;
          padding = 6;
          separator_color = "frame";
          separator_height = 2;
          transparency = 5;
          word_wrap = "yes";
        };

        urgency_critical = {
          background = "#191311";
          foreground = "#B7472A";
          frame_color = "#B7472A";
          timeout = 8;
        };

        urgency_low = {
          background = "#191311";
          foreground = "#3B7C87";
          frame_color = "#3B7C87";
          timeout = 4;
        };

        urgency_normal = {
          background = "#191311";
          foreground = "#5B8234";
          frame_color = "#5B8234";
          timeout = 6;
        };
      };
    };

    services.gnome-keyring = {
      enable = true;

      components = [ "pkcs11" "secrets" "ssh" ];
    };

    services.mpris-proxy.enable = true;

    services.picom = {
      enable = true;

      activeOpacity = 1;
      inactiveOpacity = 0.8;

      fade = true;
      fadeDelta = 5;
      fadeSteps = [ 0.02 0.02 ];

      opacityRules = [
        "99:class_g = 'Rofi'"
      ];
    };

    # inactive-opacity = 0.8;
    # active-opacity = 1;

    # fading = true;
    # fade-delta = 5;
    # fade-in-step = 0.02;
    # fade-out-step = 0.02;

    # opacity-rule = ["99:class_g = 'Rofi'"];

    services.polybar = {
      enable = true;

      extraConfig = ''
        [bar/mybar]
        modules-left = i3 music
        modules-right = battery network headphones pulseaudio date powermenu
        module-margin = 1

        padding-right = 2

        height = 36

        font-0 = "Fira Mono:pixelsize=9.5;1"
        font-1 = "Noto Sans Mono CJK JP:pixelsize=9;1"
        font-2 = "Font Awesome 6 Free Solid:style=Solid:pixelsize=9;1"
        font-3 = "Font Awesome 6 Brands Regular:style=Solid:pixelsize=9;1"
        font-4 = "Noto Color Emoji:style=Regular:scale=11;1"

        tray-position = center
        tray-maxsize = 14
        tray-padding = 4

        [module/i3]
        type = internal/i3
        pin-workspaces = true
        index-sort = true

        ws-icon-0 = 1;
        ws-icon-1 = 2;
        ws-icon-2 = 3;
        ws-icon-3 = 4;
        ws-icon-4 = 5;
        ws-icon-5 = 6;
        ws-icon-6 = 7;
        ws-icon-default = 

        format = <label-state> <label-mode>

        label-mode = %mode%
        label-mode-padding = 2
        label-mode-background = #e60053

        label-focused = %name% %icon%
        label-focused-foreground = #ffffff
        label-focused-background = #3f3f3f
        label-focused-underline = #fba922
        label-focused-padding = 2

        label-unfocused = %name% %icon%
        label-unfocused-padding = 2

        label-visible = %name% %icon%
        label-visible-underline = #555555
        label-visible-padding = 2

        label-urgent = %name% %icon%
        label-urgent-foreground = #000000
        label-urgent-background = #bd2c40
        label-urgent-padding = 2

        [module/music]
        type = custom/script
        interval = 1

        label = %output%
        exec = ${polybarMusic}/bin/polybar-music.sh

        click-left = playerctl plary-pause
        click-middle = playerctl play-pause
        click-right = playerctl play-pause

        [module/battery]
        type = internal/battery

        battery = BAT0
        full-at = 96
        poll-interval = 10

        time-format = %Hh:%Mm

        format-charging = <animation-charging> <label-charging>
        format-discharging = <ramp-capacity> <label-discharging>
        format-full = <ramp-capacity> <label-full>

        ramp-capacity-0 = 
        ramp-capacity-1 = 
        ramp-capacity-2 = 
        ramp-capacity-3 = 
        ramp-capacity-4 = 

        animation-charging-0 = 
        animation-charging-1 = 
        animation-charging-2 = 
        animation-charging-3 = 
        animation-charging-4 = 
        ; Framerate in milliseconds
        animation-charging-framerate = 750

        animation-discharging-0 = 
        animation-discharging-1 = 
        animation-discharging-2 = 
        animation-discharging-3 = 
        animation-discharging-4 = 
        ; Framerate in milliseconds
        animation-discharging-framerate = 500

        [module/network]
        type = internal/network
        # interface = {{ network_main_interface }}
        interval = 1.0

        format-connected = <ramp-signal> <label-connected>
        format-connected-padding = 1
        label-connected = %essid%

        format-disconnected = <label-disconnected>
        format-disconnected-padding = 1
        label-disconnected = 🚫 disconnected
        label-disconnected-foreground = #666

        ramp-signal-0 = 😱
        ramp-signal-1 = 😠
        ramp-signal-2 = 😒
        ramp-signal-3 = 😊
        ramp-signal-4 = 😃
        ramp-signal-5 = 😈

        [module/pulseaudio]
        type = internal/pulseaudio
        interval = 1

        format-volume = <ramp-volume> <label-volume>

        label-muted = 🔇 Muted
        label-muted-foreground = #666

        ramp-volume-0 = 🔈
        ramp-volume-1 = 🔉
        ramp-volume-2 = 🔊

        [module/date]
        type = internal/date
        date = %a %b %d %Y%
        time = %H:%M:%S

        label = 🕔 %date%, %time%

        [module/powermenu]
        type = custom/menu
        expand-right = true

        format-spacing = 1
        format-underline = #BF616A

        label-open = " 💔 "
        label-open-foreground = #ECEFF4
        label-close = " Cancel"
        label-close-foreground = #EBCB8B
        label-separator = |
        label-separator-foreground = #A3BE8C

        menu-0-0 = "Reboot"
        menu-0-0-exec = menu-open-1
        menu-0-1 = "Power off"
        menu-0-1-exec = menu-open-2
        menu-0-2 = "Suspend"
        menu-0-2-exec = menu-open-3
        menu-0-3 = "Log out"
        menu-0-3-exec = menu-open-4

        menu-1-0 = "Reboot"
        menu-1-0-exec = sudo reboot

        menu-2-0 = "Power off"
        menu-2-0-exec = sudo poweroff

        menu-3-0 = "Suspend"
        menu-3-0-exec = systemctl suspend -i

        menu-4-0 = "Log out"
        menu-4-0-exec = i3-msg exit

        [module/headphones]
        type = custom/script
        exec = ${polybarBluetooth}
        interval = 15
      '';

      package = pkgs.polybar.override {
        i3GapsSupport = true;
        mpdSupport = true;
        pulseSupport = true;
      };

      script = ''
        # Terminate already running bar instances
        killall -q polybar

        # Wait until the processes have been shut down
        while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

        MONITORS=($(polybar --list-monitors | /run/current-system/sw/bin/cut -d":" -f1))

        # Launch Polybar
        for i in "''${!MONITORS[@]}"; do
            #MONITOR="''${MONITORS[$i]}" polybar --reload --config=~/.config/polybar/config.''${i}.ini mybar &
            MONITOR="''${MONITORS[$i]}" polybar --reload mybar &
        done

        echo "Polybar launched..."
      '';
    };

    services.redshift = {
      enable = true;
      provider = "geoclue2";
    };

    services.screen-locker = {
      enable = true;
      inactiveInterval = 15;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
    };

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      config =
        let
          modifier = config.xsession.windowManager.i3.config.modifier;
          terminal = config.xsession.windowManager.i3.config.terminal;
        in
        lib.mkOptionDefault {
          modifier = "Mod4";
          terminal = "alacritty";

          bars = [ ];

          colors = {
            background = "#ffffff";

            focused = {
              background = "#007030";
              border = "#007030";
              childBorder = "#ffffff";
              indicator = "#2b2b2b";
              text = "#285577";
            };

            focusedInactive = {
              background = "#888888";
              border = "#2b2b2b";
              childBorder = "#ffffff";
              indicator = "#2b2b2b";
              text = "#5f676a";
            };

            unfocused = {
              background = "#888888";
              border = "#2b2b2b";
              childBorder = "#ffffff";
              indicator = "#2b2b2b";
              text = "#222222";
            };

            urgent = {
              background = "#900000";
              border = "#900000";
              childBorder = "#ffffff";
              indicator = "#2b2b2b";
              text = "#900000";
            };

            placeholder = {
              background = "#000000";
              border = "#0c0c0c";
              childBorder = "#ffffff";
              indicator = "#000000";
              text = "#0c0c0c";
            };
          };

          floating = {
            modifier = modifier;
          };

          gaps = {
            inner = 7;
            top = 0;
          };

          keybindings = {
            "${modifier}+0" = "workspace number 1";
            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4 " = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+Down" = "focus down";
            "${modifier}+Left" = "focus left";
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+Right" = "focus right";
            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3 " = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";
            "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your Wayland session.' -b 'Yes, exit i3' 'i3-msg exit'";
            "${modifier}+Shift+l" = "exec i3lock";
            "${modifier}+Shift+minus" = "move scratchpad";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+Up" = "focus up";
            "${modifier}+a" = "focus parent";
            "${modifier}+b" = "splith";
            "${modifier}+e" = "layout toggle split";
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";
            "${modifier}+minus" = "scratchpad show";
            "${modifier}+r" = "mode resize";
            "${modifier}+s" = "layout stacking";
            "${modifier}+space" = "exec rofi -show drun";
            "${modifier}+v" = "splitv";
            "${modifier}+w" = "layout tabbed";
            #"Print" = "exec grim -g "$(slurp)" $(xdg-user-dir PICTURES)/$(date +'%s_grim.png')";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioNext" = "exec playerctl next";
            "XF86AudioPlay" = "exec playerctl play-pause";
            "XF86AudioPrev" = "exec playerctl previous";
            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
            "XF86MonBrightnessUp" = "exec brightnessctl set +5%";

            "${modifier}+Shift+s" = "exec ~/.config/i3/radio.sh gui";
          };

          modes = {
            resize = {
              "Down" = "resize grow height 10 px";
              "Escape" = "mode default";
              "Left" = "resize shrink width 10 px";
              "Return" = "mode default";
              "Right" = "resize grow width 10 px";
              "Up" = "resize shrink height 10 px";
              "h" = "resize shrink width 10 px";
              "j" = "resize grow height 10 px";
              "k" = "resize shrink height 10 px";
              "l" = "resize grow width 10 px";
            };
          };

          # Fixes Polybar not starting when i3 starts
          startup = [
            { command = "systemctl --user restart polybar"; always = true; notification = false; }
          ];
        };

      extraConfig = ''







      
        font pango:monospace 8
        default_border pixel 0
        default_floating_border pixel 2
        hide_edge_borders none
        focus_wrapping no
        focus_follows_mouse yes
        focus_on_window_activation smart
        mouse_warping output
        workspace_layout default
        workspace_auto_back_and_forth no

        # XWayland version
        for_window [class="Firefox"] inhibit_idle fullscreen

        # Android emulator
        for_window [title=".*Emulator.*"] floating enable

        # Switch to workspace 1 on startup
        exec i3-msg workspace 3

        # Enable picom for window opacity and fading
        exec --no-startup-id picom --config ~/.config/i3/picom.conf 

        # Start anything that uses XDG autostart stuff
        exec dex -a

        # Start Polkit for system privilege magic
        exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

        # Start Nextcloud
        # exec --no-startup-id $HOME/.config/i3/nextcloud.sh

        # Laptop
        exec xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
        # exec xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Accel Speed" 0.45
        exec xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1

        # Machine specific
        #{{ i3_machine_specific }}
        exec --no-startup-id ${pkgs.batsignal}/bin/batsignal -f 0 -w 20 -c 10 -d 5 -m 15

        # Wallpaper
        exec --no-startup-id feh --bg-fill $HOME/.config/i3/background.jpg

        # Dunst
        exec --no-startup-id dunst

        # NetworkManager
        # exec --no-startup-id nm-applet

        # Flatpak
        exec --no-startup-id dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

        # Parcellite (clipboard)
        exec --no-startup-id parcellite
                
      '';
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

