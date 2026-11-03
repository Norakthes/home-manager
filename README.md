# home-manager

User config for all my machines, NixOS or not. System config is in
[nixos-config](https://github.com/Norakthes/nixos-config).

```
flake.nix          one homeConfiguration per host
modules/core.nix   imported everywhere (git, ssh, zsh, nvim)
modules/*.nix      optional pieces, picked per host
hosts/<host>/      what each machine imports + machine-only bits
packages/          custom packages (maple, dwmstatus), as an overlay
```

## Use

```sh
home-manager switch --flake ~/home-manager    # or: hm-switch
```

First time on a machine (no `home-manager` command yet):

```sh
nix run home-manager -- switch --flake ~/home-manager -b hm-bak
```

New machine: add `hosts/<hostname>/default.nix` and a line in `flake.nix`.

## Documents

`modules/documents.nix` syncs `~/Documents` with Syncthing via the NAS.
`modules/documents-backup.nix` backs it up daily with borgmatic to the Hetzner
Storage Box; only one machine imports it (currently fedora).

```sh
systemctl --user status syncthing borgmatic.timer
borgmatic list                      # archives
borgmatic extract --archive latest --path home/rasmus/Documents/foo
```
