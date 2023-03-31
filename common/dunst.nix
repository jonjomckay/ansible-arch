{ pkgs, ... }:

{
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
}
