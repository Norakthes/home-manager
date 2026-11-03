# Syncs ~/Documents between machines through the NAS (always on), over the
# LAN or Tailscale. Discovery and relays are off so traffic stays on those.
# Syncing is not a backup, see documents-backup.nix.
#
# New machine: import this, switch, then accept the device in the NAS
# Syncthing GUI (http://10.0.0.20:20910) and share "documents" with it.
{ config, lib, ... }:
let
  nasId = "6CAAR5Y-6ICRTFU-GXF736R-ZQYWHSU-MDIIZU7-TJPJFAU-AXVFHUM-YMEGTAE";
  nasLan = "10.0.0.20";
  nasPort = 20978;  # sync port of the TrueNAS Syncthing app
  nasTailnet = "100.102.172.29";

  nas = {
    id = nasId;
    addresses = [
      "tcp://${nasLan}:${toString nasPort}"
      "quic://${nasLan}:${toString nasPort}"
    ] ++ lib.optionals (nasTailnet != null) [
      "tcp://${nasTailnet}:${toString nasPort}"
      "quic://${nasTailnet}:${toString nasPort}"
    ];
  };
in
{
  services.syncthing = {
    enable = true;

    # Devices and folders come only from this file, GUI edits get reverted
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options = {
        urAccepted = -1;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };

      devices = { inherit nas; };

      folders.documents = {
        id = "documents";
        label = "Documents";
        path = "${config.home.homeDirectory}/Documents";
        devices = [ "nas" ];

        # Keeps 30 days of versions of files changed or deleted by other machines
        versioning = {
          type = "staggered";
          params.maxAge = toString (30 * 24 * 3600);
        };

        # (?d): allowed to be deleted when it blocks removing a directory
        ignorePatterns = [
          "(?d)*.o"
          "(?d)*.a"
          "(?d)*.so"
          "(?d)*.dll"
          "(?d)*.dylib"
          "(?d)build"
          "(?d)target"
          "(?d)node_modules"
          "(?d)__pycache__"
          "(?d).cache"
          "(?d)result"
          "(?d)*.swp"
          "(?d).DS_Store"
          "(?d)Thumbs.db"
        ];
      };
    };
  };
}
