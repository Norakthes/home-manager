# YubiKey tools, gpg-agent (also used as ssh-agent) and touch notifications.
# pcscd, udev rules and PAM u2f login are system config.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yubikey-manager
    yubioath-flutter
    yubikey-personalization

    libfido2

    age-plugin-yubikey
  ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 30;
    maxCacheTtl = 60;
  };

  systemd.user.services.yubikey-touch-detector = {
    Unit.Description = "YubiKey touch detector";
    Service = {
      ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector --libnotify";
      Environment = "PATH=${pkgs.gnupg}/bin";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
