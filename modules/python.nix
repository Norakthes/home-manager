{ config, pkgs, ...}:
{
  home.packages = [ pkgs.uv ];

  programs.zsh.shellAliases = {
    "uv-init" = "uv init";
    "uv-add" = "uv add";
    "uv-run" = "uv run";
    "uv-sync" = "uv sync";

    "venv-create" = "uv venv";
    "venv-activate" = "source .venv/bin/activate";
  };

  home.sessionVariables = {
    UV_CACHE_DIR = "${config.home.homeDirectory}/.cache/uv";
    UV_PYTHON_PREFERENCE = "only-system";
  };
}
