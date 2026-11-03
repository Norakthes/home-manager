# Game launchers and tools. Steam, gamemode and GPU drivers are system config.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mangohud
    protonup-qt
    lutris
    #bottles
    heroic
    gamescope
  ];
}
