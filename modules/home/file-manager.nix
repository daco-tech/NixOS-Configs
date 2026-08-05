# Nautilus (GNOME Files) — picked over a lighter tiling-WM-standard option
# like Thunar because this setup already leans on GNOME plumbing (Evolution,
# GNOME Online Accounts, gnome-keyring, gvfs — see modules/nixos/desktop/pim.nix
# and modules/nixos/desktop/niri.nix), so it integrates without adding a
# second toolkit's worth of dependencies. Automounting a USB drive (NTFS or
# FAT32 — see modules/nixos/hardware/removable-media.nix) is as simple as
# clicking it in the sidebar; right-click -> Eject before pulling it out.
{
  flake.homeModules.file-manager-user =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nautilus ];
    };
}
