# Desktop notification when a user service fails. Hook a service up with
#   Unit.OnFailure = [ "notify-failure@%n.service" ];
{ pkgs, ... }:
{
  systemd.user.services."notify-failure@" = {
    Unit.Description = "Notify that %i failed";
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.libnotify}/bin/notify-send --urgency=critical --app-name=systemd \
          "%i failed" "journalctl --user -u %i"
      '';
    };
  };
}
