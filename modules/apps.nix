{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      libreoffice
      shellcheck
      zed-editor
      gnome-calculator
      maple
      file-roller
      geogebra
      rbw
      rofi-rbw
      qbittorrent
      wineWow64Packages.stable
      cryptsetup
      google-chrome
    ];
  };
}
