# Overlay with the custom packages in this directory
final: prev: {
  dwmstatus = final.callPackage ./dwmstatus {};
  maple = final.callPackage ./maple {};
  graalvm-oracle_21 = final.callPackage ./graalvm-oracle-21.nix {};
}
