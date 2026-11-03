# Daily borg backup of ~/Documents to the Hetzner Storage Box. Syncthing keeps
# Documents identical everywhere, so one machine importing this is enough.
# Passphrase: ~/.config/borg/passphrase, ssh key: see ssh.nix.
{ config, ... }:
{
  imports = [ ./notify-failure.nix ];

  programs.borgmatic = {
    enable = true;

    # borgmatic's own config keys, written out as its YAML
    backups.documents.settings = {
      source_directories = [ "${config.home.homeDirectory}/Documents" ];
      repositories = [
        { path = "ssh://hetzner-storagebox/./documents-borg"; label = "hetzner"; }
      ];
      exclude_patterns = [
        "*/.stversions"
        "*/.stfolder"
      ];

      archive_name_format = "{hostname}-{now:%Y-%m-%d_%H-%M}";
      compression = "zstd";
      encryption_passcommand = "cat ${config.xdg.configHome}/borg/passphrase";
      # Only read our ssh config: distro ones (Fedora's crypto-policies)
      # can contain options nix's ssh rejects
      ssh_command = "ssh -F ${config.home.homeDirectory}/.ssh/config";

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 6;

      checks = [
        { name = "repository"; frequency = "2 weeks"; }
        { name = "archives"; frequency = "4 weeks"; }
      ];
    };
  };

  services.borgmatic = {
    enable = true;
    frequency = "daily";
  };
  systemd.user.services.borgmatic.Unit.OnFailure = [ "notify-failure@%n.service" ];
}
