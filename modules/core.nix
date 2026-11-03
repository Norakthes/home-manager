# Imported by every host. Keep this to things that work on any Linux.
{ config, ... }:
{
  imports = [
    ./distro-packages.nix
    ./git.nix
    ./ssh.nix
    ./nixvim.nix
    ./nvim-debug.nix
    ./zsh.nix
  ];

  home.username = "rasmus";
  home.homeDirectory = "/home/rasmus";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Lets plain `home-manager switch/news/...` find this repo without --flake
  xdg.configFile."home-manager".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/home-manager";

  # Old home-manager generations pin store paths, clean them up
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
