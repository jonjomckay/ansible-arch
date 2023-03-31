{ pkgs, config, ... }:

{
  enable = true;
  settings = {
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
}