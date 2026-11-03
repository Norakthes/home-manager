# Daily borg backup of ~/Documents to the Hetzner Storage Box. Syncthing keeps
# Documents identical everywhere, so one machine importing this is enough.
# Passphrase: ~/.config/borg/passphrase, ssh key: see ssh.nix.
{ config, ... }:
{
  programs.borgmatic = {
    enable = true;

    backups.documents = {
      location = {
        sourceDirectories = [ "${config.home.homeDirectory}/Documents" ];
        repositories = [
          { path = "ssh://hetzner-storagebox/./documents-borg"; label = "hetzner"; }
        ];
        extraConfig = {
          archive_name_format = "{hostname}-{now:%Y-%m-%d_%H-%M}";
          compression = "zstd";
          # Only read our ssh config: distro ones (Fedora's crypto-policies)
          # can contain options nix's ssh rejects
          ssh_command = "ssh -F ${config.home.homeDirectory}/.ssh/config";
          exclude_patterns = [
            "*/.stversions"
            "*/.stfolder"
          ];
        };
      };

      storage.encryptionPasscommand = "cat ${config.xdg.configHome}/borg/passphrase";

      retention = {
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 6;
      };

      consistency.checks = [
        { name = "repository"; frequency = "2 weeks"; }
        { name = "archives"; frequency = "4 weeks"; }
      ];
    };
  };

  services.borgmatic = {
    enable = true;
    frequency = "daily";
  };
}
