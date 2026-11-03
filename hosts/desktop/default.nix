# Desktop PC when booted into NixOS
{ ... }:
{
  imports = [
    ../../modules/workstation.nix
    ../../modules/toolchain.nix
    ../../modules/nixos-aliases.nix
    ../../modules/dwm.nix
    ../../modules/gaming.nix
    ../../modules/documents.nix
  ];
}
