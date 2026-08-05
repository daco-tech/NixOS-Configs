# daco-book NixOS configuration

Flake-based NixOS + Home Manager configuration for `daco-book`, a Lenovo
ThinkPad X1 Extreme Gen 4, using the [Dendritic
pattern](https://github.com/mightyiam/dendritic) (`flake-parts` +
`import-tree`): every file under `modules/` is auto-imported and contributes
`flake.nixosModules.*` / `flake.homeModules.*` pieces, which `hosts/*` files
then assemble into a bootable system.

## Layout

- `flake.nix` — inputs only. `outputs` is one line: `flake-parts.lib.mkFlake`
  fed the whole `modules/` tree via `import-tree`.
- `modules/flake/` — flake-parts plumbing shared by every host (systems list,
  the `flake.homeModules` option declaration).
- `modules/nixos/core/` — settings every host wants regardless of hardware
  (nix settings, boot, locale, networking, users, fonts, shell).
- `modules/nixos/hardware/` — this laptop's hardware quirks (hybrid NVIDIA
  graphics, audio/bluetooth, power/thermal, fingerprint reader, removable
  media, nixos-hardware's X1 Extreme Gen 4 module).
- `modules/nixos/desktop/` — niri (Wayland compositor), Noctalia (shell/bar),
  greetd (login manager), PIM (mail/calendar plumbing).
- `modules/nixos/hosts/x1-extreme.nix` — the one place that assembles all of
  the above into `flake.nixosConfigurations.x1-extreme`.
- `modules/home/` — per-user Home Manager pieces (niri keybinds, Noctalia
  theme, shell/terminal, dev tools, mail, file manager, apps), combined by
  `modules/home/default.nix` into `flake.homeModules.desktop-profile`.
- `hosts/x1-extreme/hardware-configuration.nix` — the real, machine-specific
  output of `nixos-generate-config` for this laptop. Never hand-edit; if the
  disk layout changes, regenerate and overwrite it wholesale.

Adding a second machine means adding a second `modules/nixos/hosts/<name>.nix`
+ `hosts/<name>/hardware-configuration.nix` pair — `flake.nix` itself never
changes.

## Rebuilding

```sh
sudo nixos-rebuild switch --flake .#x1-extreme
```

Run from inside this directory (or pass `--flake /path/to/this/dir#x1-extreme`
from elsewhere). `home-manager` is wired in as a NixOS module, so this single
command rebuilds both the system and the `dcosta` user's Home Manager
profile.

To try changes without committing to them as the boot default:

```sh
sudo nixos-rebuild test --flake .#x1-extreme
```

## Notes

- `system.stateVersion` (in `modules/nixos/hosts/x1-extreme.nix`) and
  `home.stateVersion` (in `modules/home/default.nix`) are set once, at
  install time, and then never bumped — see the NixOS and Home Manager
  release notes before ever touching either.
- `users.users.dcosta.initialPassword` in `modules/nixos/core/users.nix` only
  takes effect on account creation; run `passwd` after first login.
- PCI bus IDs for PRIME offload (`modules/nixos/hardware/graphics-hybrid.nix`)
  were set for a typical X1 Extreme Gen 4 board; confirm with
  `lspci | grep -E "VGA|3D"` if graphics don't come up correctly on new
  hardware.
