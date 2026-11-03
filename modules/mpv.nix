{ config, pkgs, ...}:
{
  programs.mpv = {
    enable = true;

    config = {
      screenshot-directory = "~/Pictures/mpv-screenshots";
      save-position-on-quit = true;
      cache = true;
      demuxer-max-bytes = "512MiB";
      audio-channels = "stereo";

      # HDR to SDR tone mapping
      target-trc = "srgb";
      tone-mapping = "hable";
      tone-mapping-max-boost = 1.0;
      hdr-compute-peak = "yes";

      vo = "gpu-next";
      hwdec = "auto-safe";
    };

    bindings = {
      "T" = "add sub-pos -1";
      "r" = "cycle_values video-rotate 90 180 270 0";

      "+" = "add video-zoom +0.25";
      "-" = "add video-zoom -0.25";
      "Ctrl++" = "add video-zoom +0.1";
      "Ctrl+-" = "add video-zoom -0.1";
      "Ctrl+?" = "add video-zoom +0.01";
      "Ctrl+_" = "add video-zoom -0.01";
      "Ctrl+0" = "set video-zoom 0";

      "Alt+Shift+left" = "add video-pan-x  0.01";
      "Alt+Shift+right" = "add video-pan-x -0.01";
      "Alt+Shift+up" = "add video-pan-y  0.01";
      "Alt+Shift+down" = "add video-pan-y -0.01";
      "CTRL+2" = "cycle-values tone-mapping \"spline\" \"bt.2446a\" \"st2094-40\" ; show-text \"Tone-Map\"";
    };
  };

  home.packages = [ pkgs.yt-dlp ];
}
