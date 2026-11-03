# Overlay with the custom packages in this directory
final: prev: {
  dwmstatus = final.callPackage ./dwmstatus {};
  maple = final.callPackage ./maple {};
}
