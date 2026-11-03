# nixpkgs has Oracle GraalVM 17 and 25 but dropped 21. Same build as theirs
# (pkgs/development/compilers/graalvm/graalvm-oracle). Hash is the .sha256
# Oracle publishes next to the tarball.
{ lib, fetchurl, graalvmPackages }:

graalvmPackages.buildGraalvm rec {
  pname = "graalvm-oracle";
  version = "21.0.12";
  src = fetchurl {
    url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-${version}_linux-x64_bin.tar.gz";
    hash = "sha256-sAf/ZMQl+Fu+DmhhBwRPumylBUp+iScaRzdn9Uaq3cE=";
  };
  meta.platforms = [ "x86_64-linux" ];
  meta.license = lib.licenses.unfree;
}
