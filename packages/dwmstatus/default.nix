{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:
pkgs.clangStdenv.mkDerivation {
  pname = "dwmstatus";
  version = "1.0";

  src = ./.;

  buildInputs = with pkgs; [
    libx11
  ];

  CFLAGS = "-O3 -flto -std=c23 -pedantic -Wall";
  LDFLAGS = "-flto -s";

  buildPhase = ''
    $CC $CFLAGS -o dwmstatus dwmstatus.c -lX11 $LDFLAGS
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 dwmstatus $out/bin/dwmstatus
  '';

  meta = with lib; {
    description = "Simple status bar for dwm";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
