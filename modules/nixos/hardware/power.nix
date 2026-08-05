# Power/thermal management. `power-profiles-daemon` is also turned on by
# noctalia's `recommendedServices` (modules/nixos/desktop/noctalia.nix) since
# Noctalia's quick-settings panel talks to it directly for the
# battery/performance toggle; it's declared again here with `mkDefault` so
# this module stands on its own too.
{
  flake.nixosModules.hw-power =
    { lib, ... }:
    {
      services.power-profiles-daemon.enable = lib.mkDefault true;

      # Intel P-state thermal throttling daemon; avoids the CPU sitting at a
      # conservative clock permanently after a thermal spike.
      services.thermald.enable = true;

      # Firmware updates (BIOS/EC/Thunderbolt) via LVFS — ThinkPads are
      # well-supported.
      services.fwupd.enable = true;

      powerManagement.enable = true;
    };
}
