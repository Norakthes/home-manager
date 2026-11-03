{ config, pkgs, ...}:
{
  home.packages = with pkgs; [
    uv

    (python3.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
      virtualenv

      jupyter
      jupyterlab
      notebook
      ipykernel

      requests
      pyyaml
      click
      rich

      numpy
      pandas
      matplotlib
      scipy
      statsmodels
    ]))
  ];

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

  home.file.".uvrc".text = ''
    python-preference = "only-system"
    cache-dir = "${config.home.homeDirectory}/.cache/uv"
  '';
}
