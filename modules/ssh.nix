{ lib, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };

      "hpc" = {
        HostName = "login1.gbar.dtu.dk";
        User = "s235765";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = true;
      };

      # Hetzner Storage Box, holds the borg backups (see documents.nix)
      "hetzner-storagebox" = {
        HostName = "u464102.your-storagebox.de";
        User = "u464102";
        Port = 23;
        IdentityFile = "~/.ssh/hetzner_docsync";
      };

      # NAS over Tailscale, so these work the same from anywhere
      "nas" = {
        HostName = "100.102.172.29";
        User = "truenas_admin";
      };

      # BorgWarehouse app on the NAS, holds the borg backups
      "nas-borg" = {
        HostName = "100.102.172.29";
        User = "borgwarehouse";
        Port = 30407;
        IdentityFile = "~/.ssh/nas_borg";
        IdentitiesOnly = true;
      };

      # Defaults for everything else, must come last
      "*" = lib.hm.dag.entryAfter [ "github.com" "hpc" "hetzner-storagebox" "nas" "nas-borg" ] {
        Compression = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 10;
      };
    };
  };
}
