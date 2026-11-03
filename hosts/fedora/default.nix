# Desktop PC running Fedora
{ pkgs, lib, ... }:
{
  imports = [
    ../../modules/native-first.nix
    ../../modules/workstation.nix
    ../../modules/documents.nix
    ../../modules/documents-backup.nix
  ];

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/Documents/Code/c64/llvm-mos-linux/llvm-mos/bin"
  ];

  home.sessionVariables = {
    # Xilinx 2018.2 + zybovio
    XILINX_ROOT = "/mnt/storage/Xilinx";
    ZYBOVIO_LABS = "/mnt/storage/fpga";
  };

  programs.git.signing = {
    format = "openpgp";
    key = "649B245913D8A39C";
    signer = "/usr/bin/gpg";  # the key lives in Fedora's gpg/keyboxd
  };

  # Fedora's own platformio and zig installs
  programs.vscode.profiles.default.userSettings = {
    "platformio-ide.customPATH" = "/usr/bin";
    "platformio-ide.useBuiltinPIOCore" = false;
    "zig.path" = "/home/rasmus/.local/bin/zig";
  };

  programs.zsh = {
    shellAliases = {
      nix-clean = "nix-collect-garbage --delete-older-than 4d";

      zybovio = "$HOME/Downloads/vio/zybovio/.venv/bin/zybovio";
      vio-lab = "zybovio lab";  # old name: vio-lab <name> == zybovio lab <name>
    };

    initContent = lib.mkMerge [
      ''
        # Xilinx tools run in a subshell, so settings64.sh (PATH/LD_LIBRARY_PATH changes) never
        # leaks into the rest of the shell. The Vivado GUI runs in its own XWayland window via
        # x11-run, because Vivado 2018's Java crashes on plain Wayland; batch mode runs directly.
        vivado() {
            if [[ " $* " == *" batch "* || " $* " == *" tcl "* ]]; then
                ( source $XILINX_ROOT/Vivado/2018.2/settings64.sh >/dev/null && command vivado "$@" )
            else
                ( source $XILINX_ROOT/Vivado/2018.2/settings64.sh >/dev/null && x11-run vivado "$@" )
            fi
        }
        xsdk()   { ( source $XILINX_ROOT/SDK/2018.2/settings64.sh >/dev/null && SWT_GTK3=0 command xsdk "$@" ) }
        xsdb()   { ( source $XILINX_ROOT/SDK/2018.2/settings64.sh >/dev/null && command xsdb "$@" ) }
      ''
      # SDKMAN wants to be last. Aliases are off while sourcing it since it
      # calls find/grep, which are aliased to fd/rg above.
      (lib.mkOrder 1500 ''
        export SDKMAN_DIR="$HOME/.sdkman"
        if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
          setopt no_aliases
          source "$SDKMAN_DIR/bin/sdkman-init.sh"
          setopt aliases
        fi
      '')
    ];
  };

  # Kanata keyboard remapper. On NixOS this is a system service; here it runs
  # as the user, which needs the input + uinput groups and a udev rule giving
  # the uinput group access to /dev/uinput (both already set up on Fedora).
  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata keyboard remapper";
      After = [ "local-fs.target" ];
    };
    Service = {
      ExecStart = "${pkgs.kanata-with-cmd}/bin/kanata --cfg ${./kanata.kbd}";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
