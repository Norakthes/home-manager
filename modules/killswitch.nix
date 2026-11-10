# killswitch on|off|status: temporarily stops Syncthing, borg backups and
# Tailscale, for when nothing should be sending files (an exam, say).
#
# On is a flag file that the units check before starting, so it holds across
# reboots and home-manager switch. A skipped start is not a failure, so no
# failure notifications either. Tailscale remembers being down by itself, but
# needs this user as its operator (sudo tailscale set --operator=$USER).
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
          tailscale down || echo "killswitch: could not stop Tailscale" >&2
          ;;
        off)
          rm -f "$flag"
          tailscale up || echo "killswitch: could not start Tailscale" >&2
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
      if tailscale status >/dev/null 2>&1; then echo "  tailscale: up"; else echo "  tailscale: down"; fi
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
