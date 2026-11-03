# Rebuild shortcuts for hosts running NixOS (system config in ~/nixos-config)
{ ... }:
{
  programs.zsh = {
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config";
      nix-dry = "sudo nixos-rebuild dry-run --flake ~/nixos-config";
      nix-boot = "sudo nixos-rebuild boot --flake ~/nixos-config";
      nix-test = "sudo nixos-rebuild test --flake ~/nixos-config";
      nix-clean = "sudo nix-collect-garbage --delete-older-than 4d";
    };

    # Smart nixos-rebuild function (overrides the original command)
    initContent = ''
      nixos-rebuild() {
        local action="''${1:-switch}"
        sudo nixos-rebuild "$action" --flake ~/nixos-config "''${@:2}"
      }
    '';
  };
}
