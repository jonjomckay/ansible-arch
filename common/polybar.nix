{ pkgs, ... }:

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
}
