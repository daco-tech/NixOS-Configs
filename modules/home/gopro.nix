# GoPro Hero workflow: import, edit, playback.
#
# Getting footage off the camera — no extra packages needed for either path,
# just existing plumbing:
# - USB cable, camera in mass-storage mode: shows up like any other drive via
#   `services.udisks2.enable` (modules/nixos/hardware/removable-media.nix),
#   mountable/browsable straight from Nautilus.
# - USB cable, camera in MTP mode (or the SD card pulled and read via a
#   reader, if you'd rather skip the cable): `services.gvfs.enable`
#   (modules/nixos/desktop/niri.nix) already ships the MTP backend, so it
#   just appears in Nautilus's sidebar.
# - SD card path specifically needs the "exfat" addition in
#   removable-media.nix — GoPro ships larger SDXC cards (64GB+, needed for
#   4K/5.3K60 footage) preformatted exFAT rather than FAT32.
{
  flake.homeModules.gopro-user =
    { pkgs, ... }:
    {
      home.packages = [
        # Purpose-built camera/card import tool (rather than plain drag-and-drop
        # in Nautilus): understands DCIM-style camera storage, and can
        # rename/organize into dated folders as it copies videos and photos off.
        pkgs.rapid-photo-downloader

        # Qt6/KDE Frameworks NLE — moved under kdePackages.* rather than
        # top-level in this nixpkgs revision. Chosen over a lighter cutter
        # (e.g. Shotcut) because GoPro footage is routinely 4K/5.3K60 HEVC at
        # a high bitrate; Kdenlive's proxy-clip workflow (Project ->
        # Proxy Clips) generates a low-res stand-in to edit against and swaps
        # back to the original for the final render, which is what keeps the
        # timeline scrubbable on a laptop iGPU instead of dropping frames.
        pkgs.kdePackages.kdenlive

        # CLI companion for the one thing Kdenlive's GUI doesn't do well:
        # GoPro auto-splits any recording past ~4GB into numbered chapter
        # files (GX010001.MP4, GX020001.MP4, ...) that need concatenating
        # before they're one clip. `ffmpeg -f concat` handles that losslessly;
        # `-full` (rather than the default build) adds libx265/libvpx so
        # transcodes out of HEVC aren't limited to copy-only operations.
        pkgs.ffmpeg-full

        # Playback. VLC over mpv here specifically because this is meant to
        # be a normal double-click-and-watch experience (seek bar, volume,
        # fullscreen button) rather than a keybinding-driven player — and it
        # decodes GoPro's HEVC/H.265 footage via VA-API automatically using
        # the Intel iGPU already enabled in
        # modules/nixos/hardware/graphics-hybrid.nix, so 4K/5.3K60 plays back
        # smoothly without waking the dGPU.
        pkgs.vlc
      ];

      # Without these, niri has no default handler for video (same gap
      # file-manager.nix fills for images/office docs/PDF) — double-clicking
      # a GoPro .MP4 in Nautilus, or opening one from the mounted
      # camera/SD card, would otherwise fail instead of opening in VLC.
      # video/quicktime is here for older Hero models, which used .MOV.
      xdg.mimeApps.defaultApplications = {
        "video/mp4" = "vlc.desktop";
        "video/quicktime" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
      };
    };
}
