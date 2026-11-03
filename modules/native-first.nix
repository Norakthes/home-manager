# For non-NixOS hosts: the distro's packages win over nix ones, so they get
# updated by the distro's package manager. Nix only fills in what the distro
# lacks. nvim is the exception since nixvim's build carries the plugins.
{ config, pkgs, ... }:
let
  nixvim = pkgs.runCommand "nixvim-bin" { } ''
    mkdir -p $out/bin
    ln -s ${config.programs.nixvim.build.package}/bin/nvim $out/bin/nvim
  '';

  # /etc/profile.d/nix.sh puts the nix profiles in front of /usr/bin; move them
  # to the back. KDE takes its session environment from a login shell, so
  # doing this in .zprofile covers apps started from the desktop too.
  reorderPath = ''
    path=(${nixvim}/bin ''${path:#(${nixvim}/bin|$HOME/.nix-profile/bin|/nix/var/nix/profiles/default/bin)} $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin)
    export XDG_DATA_DIRS=/usr/local/share:/usr/share:$XDG_DATA_DIRS
  '';
in
{
  # Sets XDG_DATA_DIRS, locale archive etc. so nix programs work at all
  targets.genericLinux.enable = true;

  programs.zsh.profileExtra = reorderPath;
  programs.zsh.initContent = reorderPath;

  # Same for systemd user services
  xdg.configFile."environment.d/99-native-first.conf".text = ''
    PATH=/usr/local/bin:/usr/bin:''${PATH}
    XDG_DATA_DIRS=/usr/local/share:/usr/share:''${XDG_DATA_DIRS}
  '';
}
