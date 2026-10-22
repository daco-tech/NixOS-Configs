# Support for opening USB pen drives formatted by Windows.
#
# - FAT32 (vfat) needs nothing extra — it's built into every kernel.
# - NTFS is handled by the in-kernel ntfs3 driver (mainlined since Linux
#   5.15, so linuxPackages_latest — see core/boot.nix — has it); listing
#   "ntfs" in `boot.supportedFilesystems` is what tells NixOS to make sure
#   it's built in and to pull in `ntfs3g` as a fallback/tools package
#   (mount.ntfs-3g, ntfsfix, etc.) for anything the in-kernel driver won't
#   touch (e.g. a volume Windows left in a dirty/hibernated state).
# - exFAT is here for GoPro SD cards: the larger SDXC cards GoPro needs for
#   4K/5.3K60 footage (64GB+) ship preformatted exFAT rather than FAT32.
#   Listing "exfat" pulls in the in-kernel driver (mainlined since 5.7, well
#   below what linuxPackages_latest ships) plus `exfatprogs` for mkfs/fsck —
#   see nixos/modules/tasks/filesystems/exfat.nix, which picks exfatprogs
#   over the older FUSE `exfat` package automatically once the kernel is
#   recent enough.
# - `services.udisks2` is the D-Bus mounting backend: it's what lets Nautilus
#   (modules/home/file-manager.nix) or `udisksctl mount -b /dev/sdXN` mount a
#   drive under /run/media/$USER/<label> without a root password — polkit's
#   default udisks2 rules already allow this for the active local session
#   user, so no extra polkit rule is needed here.
{
  flake.nixosModules.hw-removable-media = {
    boot.supportedFilesystems = [
      "ntfs"
      "exfat"
    ];
    services.udisks2.enable = true;
  };
}
