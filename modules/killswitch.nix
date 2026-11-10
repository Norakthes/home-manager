# killswitch on|off|status: temporarily stops Syncthing and borg backups, for
# when nothing should be sending files (an exam, say).
#
# On is a flag file that the units check before starting, so it holds across
# reboots and home-manager switch. A skipped start is not a failure, so no
# failure notifications either.
{ config, lib, pkgs, ... }:
let
  flag = "${config.xdg.stateHome}/killswitch";
  offWhenFlagged.Unit.ConditionPathExists = "!${flag}";

  hasBorgmatic = config.services.borgmatic.enable;

  killswitch = pkgs.writeShellApplication {
    name = "killswitch";
    text = ''
      flag=${lib.escapeShellArg flag}
      sync_units=(syncthing.service syncthing-init.service)
      all_units=("''${sync_units[@]}"${lib.optionalString hasBorgmatic " borgmatic.service"})

      case "''${1:-status}" in
        on)
          mkdir -p "$(dirname "$flag")"
          touch "$flag"
          systemctl --user stop "''${all_units[@]}"
          ;;
        off)
          rm -f "$flag"
          # Not borgmatic: its timer takes over, off shouldn't start a backup
          systemctl --user start "''${sync_units[@]}"
          ;;
        status) ;;
        *)
          echo "usage: killswitch on|off|status" >&2
          exit 2
          ;;
      esac

      if [[ -e "$flag" ]]; then echo "killswitch: ON"; else echo "killswitch: off"; fi
      for unit in "''${all_units[@]}"; do
        echo "  $unit: $(systemctl --user is-active "$unit" || true)"
      done
    '';
  };
in
{
  home.packages = [ killswitch ];

  systemd.user.services = {
    syncthing = offWhenFlagged;
    syncthing-init = offWhenFlagged;
    borgmatic = lib.mkIf hasBorgmatic offWhenFlagged;
  };
}
