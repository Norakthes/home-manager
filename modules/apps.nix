{ pkgs, ... }:
{
  distroPackages.candidates = with pkgs; [
    libreoffice
    shellcheck
    zed-editor
    gnome-calculator
    file-roller
    geogebra
    rbw
    rofi-rbw
    qbittorrent
    wineWow64Packages.stable
    cryptsetup
    google-chrome
  ];
}
