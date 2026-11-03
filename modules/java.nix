# JDKs at fixed paths, e.g. for PrismLauncher's per-instance Java setting:
#   ~/.local/share/java/<name>/bin/java
# The links follow nixpkgs updates. `java` on PATH is the latest one.
{ config, lib, pkgs, ... }:
let
  # The build's native-image self test segfaults now and then (seen on 17, 21
  # and 25, worse when built in parallel). Only java itself is needed here.
  noSelfTest = jdk: jdk.overrideAttrs { doInstallCheck = false; };

  jdks = lib.mapAttrs (_: noSelfTest) {
    graalvm-17 = pkgs.graalvmPackages.graalvm-oracle_17;
    graalvm-21 = pkgs.graalvm-oracle_21;
    graalvm-latest = pkgs.graalvmPackages.graalvm-oracle;
  };
  javaDir = "${config.home.homeDirectory}/.local/share/java";
in
{
  home.file = lib.mapAttrs' (name: jdk: lib.nameValuePair ".local/share/java/${name}" { source = jdk; }) jdks;

  home.packages = [ jdks.graalvm-latest ];
  home.sessionVariables.JAVA_HOME = "${javaDir}/graalvm-latest";

  # Prism is a Flatpak: let it read the links and the store paths behind them
  xdg.dataFile."flatpak/overrides/org.prismlauncher.PrismLauncher".text = ''
    [Context]
    filesystems=${javaDir}:ro;/nix/store:ro;
  '';
}
