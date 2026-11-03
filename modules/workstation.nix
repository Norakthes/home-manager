# Programs and dev tools every machine gets, so they all feel the same
{ ... }:
{
  imports = [
    ./dev.nix
    ./python.nix
    ./vscode.nix
    ./mpv.nix
    ./apps.nix
    ./embedded.nix
  ];
}
