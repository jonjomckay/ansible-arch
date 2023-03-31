{ pkgs, config, lib, ... }:

{
  enable = true;
  package = pkgs.i3-gaps;

  config =
    let
      modifier = "Mod4";
      terminal = "alacritty";
    in
    lib.mkOptionDefault {
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
        "${modifier}+Shift+l" = "exec ${pkgs.i3lock}/bin/i3lock -n -c 000000";
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
}
