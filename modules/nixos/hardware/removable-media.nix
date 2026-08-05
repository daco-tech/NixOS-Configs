# Support for opening USB pen drives formatted by Windows.
#
# - FAT32 (vfat) needs nothing extra — it's built into every kernel.
# - NTFS is handled by the in-kernel ntfs3 driver (mainlined since Linux
#   5.15, so linuxPackages_latest — see core/boot.nix — has it); listing
#   "ntfs" in `boot.supportedFilesystems` is what tells NixOS to make sure
#   it's built in and to pull in `ntfs3g` as a fallback/tools package
#   (mount.ntfs-3g, ntfsfix, etc.) for anything the in-kernel driver won't
#   touch (e.g. a volume Windows left in a dirty/hibernated state).
# - `services.udisks2` is the D-Bus mounting backend: it's what lets Nautilus
#   (modules/home/file-manager.nix) or `udisksctl mount -b /dev/sdXN` mount a
#   drive under /run/media/$USER/<label> without a root password — polkit's
#   default udisks2 rules already allow this for the active local session
#   user, so no extra polkit rule is needed here.
{
  flake.nixosModules.hw-removable-media = {
    boot.supportedFilesystems = [ "ntfs" ];
    services.udisks2.enable = true;
  };
}
