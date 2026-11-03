# ASUS Zephyrus laptop (NixOS)
{ ... }:
{
  imports = [
    ../../modules/nixos-aliases.nix
    ../../modules/dwm.nix
    ../../modules/apps.nix
    ../../modules/dev.nix
    ../../modules/python.nix
    ../../modules/vscode.nix
    ../../modules/mpv.nix
    ../../modules/embedded.nix
    ../../modules/gaming.nix
    ../../modules/yubikey.nix
    ../../modules/documents.nix
  ];

  programs.zsh.shellAliases = {
    btrfs-usage = "sudo btrfs filesystem usage /";
    btrfs-show = "sudo btrfs filesystem show";
    btrfs-compress-check = "sudo compsize /";
    btrfs-defrag = "sudo btrfs filesystem defragment -r -v -czstd /";
  };
}
