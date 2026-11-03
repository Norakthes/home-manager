# User side of the dwm X session: status bar, wallpaper, compositor, blue
# light filter, volume/brightness scripts and the usual X tools. dwm itself and
# the display manager are system config (nixos-config).
{ pkgs, inputs, ... }:
let
  changevol = pkgs.writeShellApplication {
    name = "changevol";
    runtimeInputs = with pkgs; [
      pulseaudio
      gawk
      libnotify
    ];
    text = builtins.readFile ../scripts/changevol.sh;
  };

  changebrightness = pkgs.writeShellApplication {
    name = "changebrightness";
    runtimeInputs = with pkgs; [
      brightnessctl
      libnotify
    ];
    text = builtins.readFile ../scripts/changebrightness.sh;
  };
in
{
  home.packages = with pkgs; [
    inputs.st.packages.${pkgs.stdenv.hostPlatform.system}.default
    changevol
    changebrightness

    firefox
    dmenu
    j4-dmenu-desktop
    xev
    xkill
    arc-theme

    brightnessctl
    feh
    xclip
    flameshot

    dunst
    libnotify

    transmission_4-gtk

    ffmpeg-full
    ffmpegthumbnailer
  ];

  systemd.user.services.dwmstatus = {
    Unit = {
      Description = "dwm status bar";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.dwmstatus}/bin/dwmstatus";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Random wallpaper from ../wallpapers every 10 minutes
  systemd.user.services.wallpaper = {
    Unit.Description = "Set random wallpaper";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.feh}/bin/feh --bg-scale --randomize ${../wallpapers}";
    };
  };

  systemd.user.timers.wallpaper = {
    Unit.Description = "Change wallpaper periodically";
    Timer = {
      OnStartupSec = "0";
      OnUnitActiveSec = "10min";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.picom = {
    enable = true;
    vSync = true;
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 55.68;
    longitude = 12.57;
  };
}
