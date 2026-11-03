# Migration notes (2026-11-03)

What changed when the single NixOS repo was split into this repo
(user config) and `nixos-config` (system config), and how to undo it.

## Where things went

| Before (nixos-config) | Now |
|---|---|
| `home.nix`, `home/*` (embedded in nixos-rebuild) | this repo, standalone `home-manager switch` |
| `modules/zsh.nix` (oh-my-zsh, p10k, aliases) | `modules/zsh.nix` here; system only sets zsh as login shell |
| `features/development` packages | `modules/dev.nix`, compilers in `modules/toolchain.nix` |
| `features/desktop` apps, picom, redshift | `modules/dwm.nix` (picom, gammastep) |
| `features/desktop/dwm.nix` dwmstatus service | `modules/dwm.nix` |
| `modules/wallpaper.nix`, `modules/scripts.nix` | `modules/dwm.nix` |
| `modules/yubikey.nix` tools, gpg-agent, touch detector | `modules/yubikey.nix` here; pcscd/udev/PAM stay in nixos-config |
| `modules/avr.nix`, `riscv32-dev.nix` toolchains | `modules/embedded.nix`; udev + dialout stay in nixos-config |
| `features/gaming` launchers | `modules/gaming.nix`; steam/gamemode stay in nixos-config |
| `packages/` (maple, dwmstatus), st | this repo |
| fedora `~/.config/systemd/user/docsync-*`, `~/.local/bin/docsync` | `modules/documents.nix` (Syncthing) + `modules/documents-backup.nix` (borgmatic) |
| fedora `~/.config/systemd/user/kanata.service` | `hosts/fedora/default.nix` |
| fedora `~/.zshrc`, `~/.ssh/config` | `modules/zsh.nix`, `hosts/fedora`, `modules/ssh.nix` |

## Behaviour changes

- **Documents sync**: rclone bisync to Hetzner every 15 min → Syncthing via
  the NAS (live). Hetzner only gets the daily borg backup now. The old bisync
  copy on the storage box (`documents/`) is stale.
- **Backups**: same borg repo and archive names, now run by borgmatic, which
  also prunes (7 daily, 4 weekly, 6 monthly) and runs consistency checks.
- **Tailscale** (NixOS + Fedora): no tailnet DNS, no routes. Only 100.x
  traffic uses it.
- **Fedora PATH**: dnf packages come before nix ones (`modules/native-first.nix`),
  except nvim.
- **VS Code**: `settings.json` is generated and read-only, edit `modules/vscode.nix`.
  Hand-installed extensions keep working.
- **gpg-agent** (laptop) runs as a home-manager user service instead of the
  NixOS `programs.gnupg.agent`.
- **kanata** keyboard renamed to `main` on NixOS (unit `kanata-main`).
- **TLP**: the governor settings were misspelled and never applied; they are
  removed, so behaviour is unchanged.
- **command-not-found** is off (broken on flake systems, no database).
- **dwm** now builds against the system nixpkgs instead of its own July 2025 pin.

## Bugs fixed on the way

- `home/git.nix` missing `}`: the laptop config did not evaluate.
- `vm.nix`: missing `...` in args, `spiceUSBRedirection` needed `.enable`.
- stray `kanata-internationalKeyboard` unit, udev rule with `GROUP="UINPUT"`.
- `nixos-rebuild` zsh function had escaped quotes around the flake path.
- AVR/RISC-V/native gdb file collisions (only show up in home.packages).
- `sdkman-init.sh` broke on the `find`→`fd` / `grep`→`rg` aliases.
- nix's ssh rejects Fedora's `/etc/ssh/ssh_config` (crypto-policies), so
  borgmatic uses `ssh -F ~/.ssh/config`.

## Verified

- fedora: kanata, syncthing, borgmatic timer active; manual backup ran,
  restored file byte-identical; NAS connected over LAN and reachable over
  the tailnet; nvim-dap stops at breakpoints with gdb and lldb.
- laptop/desktop: NixOS and home configs evaluate; NixOS output diffed
  against the old config (only the changes listed above).

## Not verified yet

- laptop and NixOS desktop never built or booted with the new configs
  (dwm session units now come from home-manager, gpg-agent moved).
- the laptop home can't be built without the maple installer in its store.
- fedora: `workstation.nix`/`native-first.nix` not activated yet; KDE
  session PATH only changes after logging out and in.

## Switching a NixOS machine over

Order matters. The old system generation still owns the user environment
(it used home-manager as a NixOS module), and nix.gc deletes it 4 days after
nixos-rebuild. Without a standalone home-manager by then, ~/.zshrc and friends
dangle.

1. Move `~/Documents` aside (Syncthing would merge stale files back).
2. `nix run home-manager -- switch --flake ~/home-manager -b hm-bak`
3. `sudo nixos-rebuild test --flake ~/nixos-config`, log out and in, check
   dwm session, status bar, picom, gpg/ssh agent.
4. `sudo nixos-rebuild switch --flake ~/nixos-config`
5. Accept the device in the NAS Syncthing GUI and share `documents`.
6. Commit signing: set the yubikey's GPG key in `hosts/laptop`
   (`programs.git.signing = { format = "openpgp"; key = "<id>"; };`,
   id from `gpg --card-status`). Until then it signs with `~/.ssh/id_ed25519`.

## Rolling back

- **home-manager**: `home-manager generations`, then run
  `<generation path>/activate` of an older one. Replaced files are kept as
  `*.hm-bak`.
- **NixOS**: pick the previous generation in the boot menu, or
  `sudo nixos-rebuild switch --rollback`. The old config is on `main` of
  nixos-config; the new one is on `standalone-home-manager`.
- **docsync**: the old script was never committed. A copy lives at
  `/nix/store/h23z2dhcq173fia5zq8sqjw6qs0lp181-docsync/bin/docsync` until nix-gc
  removes it; copy it out if you might want it back.
- **Documents**: every daily state is in borg (`borgmatic repo-list`,
  `borgmatic extract`); Syncthing also keeps 30 days of versions on fedora in
  `~/Documents/.stversions`.

## Outside nix (set up by hand on Fedora)

- nix daemon (`nix-daemon.socket`), flakes enabled in `/etc/nix/nix.conf`
- tailscale (dnf, `tailscale set --accept-dns=false --accept-routes=false`)
- kanata: user in `input` + `uinput` groups, udev rule for `/dev/uinput`
- linger for rasmus (Syncthing/borgmatic run while logged out)
- secrets: `~/.ssh/id_ed25519`, `~/.ssh/hetzner_docsync`, `~/.config/borg/passphrase`
