# Packages a distro may already ship. Modules put them in
# distroPackages.candidates instead of home.packages; a host lists the ones its
# distro provides in distroPackages.provided and nix skips those.
{ config, lib, ... }:
let
  cfg = config.distroPackages;
in
{
  options.distroPackages = {
    candidates = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
    };
    provided = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Names (lib.getName) of candidates the distro already provides.";
    };
  };

  config.home.packages = lib.filter (p: !lib.elem (lib.getName p) cfg.provided) cfg.candidates;
}
