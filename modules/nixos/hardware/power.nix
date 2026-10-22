# Power/thermal management. `power-profiles-daemon` is also turned on by
# noctalia's `recommendedServices` (modules/nixos/desktop/noctalia.nix) since
# Noctalia's quick-settings panel talks to it directly for the
# battery/performance toggle; it's declared again here with `mkDefault` so
# this module stands on its own too.
{
  flake.nixosModules.hw-power =
    { lib, pkgs, ... }:
    {
      services.power-profiles-daemon.enable = lib.mkDefault true;

      # Intel P-state thermal throttling daemon; avoids the CPU sitting at a
      # conservative clock permanently after a thermal spike.
      services.thermald.enable = true;

      # Firmware updates (BIOS/EC/Thunderbolt) via LVFS — ThinkPads are
      # well-supported.
      services.fwupd.enable = true;

      powerManagement.enable = true;

      # Backlight control (XF86MonBrightness{Up,Down} keys, see
      # modules/home/niri.nix). /sys/class/backlight/*/brightness is
      # root-only by default; this rule hands write access to the `video`
      # group instead of setuid-wrapping brightnessctl, matching the `video`
      # membership already granted in modules/nixos/core/users.nix.
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
      '';

      environment.systemPackages = [ pkgs.brightnessctl ];
    };
}
