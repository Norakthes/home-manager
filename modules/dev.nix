# Development tools and environment
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    file
    hexdump
    xxd

    lldb
    strace
    ltrace
    valgrind
    perf-tools

    ghex
    okteta

    jq
    yq

    diff-so-fancy
    delta
    tig

    patchelf

    netcat
    nmap
    wireshark

    iotop
    lsof

    docker
    docker-compose

    nil
    taplo
    yaml-language-server

    nodejs

    man-pages
    man-pages-posix
  ];

  home.sessionVariables = {
    LESS = "-R";
    PAGER = "less";
    GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
