# Compilers, build tools and the Python interpreter. Only for NixOS: on other
# distros nix's gcc can't see /usr/include and /usr/lib, and nix's python3 would
# hide pip --user packages, so there these come from the distro instead.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnumake
    cmake
    meson
    ninja

    gcc
    clang
    clang-tools
    llvm
    llvmPackages.openmp
    binutils

    (python3.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
      virtualenv

      jupyter
      jupyterlab
      notebook
      ipykernel

      requests
      pyyaml
      click
      rich

      numpy
      pandas
      matplotlib
      scipy
      statsmodels
    ]))
  ];
}
