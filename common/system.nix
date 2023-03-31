{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  environment.pathsToLink = [ "/share/zsh" ];
  environment.systemPackages = with pkgs; [
    aria2
    bat
    bind
    bmon
    htop
    inetutils
    iotop
    jq
    nixpkgs-fmt
    rsync
    vim
    wget
    whois
  ];

  i18n.defaultLocale = "en_GB.UTF-8";

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.timesyncd.enable = true;

  time.timeZone = "Europe/London";
}