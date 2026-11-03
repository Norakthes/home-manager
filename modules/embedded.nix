# Cross toolchains for AVR and RISC-V. Serial port access (dialout group) and
# programmer udev rules are system config.
{ pkgs, ... }:
let
  riscv32Pkgs = import pkgs.path {
    system = pkgs.stdenv.system;
    crossSystem = {
      config = "riscv32-unknown-linux-gnu";
    };
  };
in
{
  home.packages = with pkgs; [
    # AVR toolchain
    pkgsCross.avr.buildPackages.gcc
    pkgsCross.avr.buildPackages.binutils
    pkgsCross.avr.buildPackages.gdb
    avrdude
    compiledb

    simavr

    picocom
    minicom
    screen

    # RISC-V toolchain
    riscv32Pkgs.buildPackages.gcc
    riscv32Pkgs.buildPackages.binutils
    riscv32Pkgs.buildPackages.gdb
    qemu  # Includes RISC-V system and user mode emulation
  ];
}
