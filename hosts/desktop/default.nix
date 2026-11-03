# Desktop PC when booted into NixOS
{ ... }:
{
  imports = [
    ../../modules/nixos-aliases.nix
    ../../modules/dwm.nix
    ../../modules/apps.nix
    ../../modules/python.nix
    ../../modules/vscode.nix
    ../../modules/mpv.nix
    ../../modules/gaming.nix
  ];
}
