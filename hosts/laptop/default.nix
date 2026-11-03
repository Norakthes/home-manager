# ASUS Zephyrus laptop (NixOS)
{ pkgs, ... }:
{
  imports = [
    ../../modules/workstation.nix
    ../../modules/toolchain.nix
    ../../modules/nixos-aliases.nix
    ../../modules/dwm.nix
    ../../modules/gaming.nix
    ../../modules/yubikey.nix
    ../../modules/documents.nix
  ];

  # Needs the installer added to the store by hand, see packages/maple
  home.packages = [ pkgs.maple ];

  programs.zsh.shellAliases = {
    btrfs-usage = "sudo btrfs filesystem usage /";
    btrfs-show = "sudo btrfs filesystem show";
    btrfs-compress-check = "sudo compsize /";
    btrfs-defrag = "sudo btrfs filesystem defragment -r -v -czstd /";
  };
}
