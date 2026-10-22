{
  flake.nixosModules.hw-audio-bluetooth =
    { pkgs, ... }:
    {
      security.rtkit.enable = true; # required by pipewire
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # Bluetooth headset/speaker audio (A2DP) is a wireplumber module,
        # covered by this — no separate package needed for a Bluetooth mouse,
        # keyboard, or speakers to work once paired.
        wireplumber.enable = true;
      };

      # `wpctl` (used by the volume/mic keybinds in modules/home/niri.nix)
      # ships in the wireplumber package; the service module above pulls
      # wireplumber in for the daemon but doesn't guarantee its CLI is on
      # PATH, so add it explicitly.
      environment.systemPackages = [ pkgs.wireplumber ];

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General.Experimental = true; # battery %, better codec negotiation in most Bluetooth UIs
      };

      # Pairing a mouse/keyboard/speakers day-to-day: Noctalia's own Control
      # Center has a Bluetooth panel (scan, pair, connect) that covers most
      # devices. `blueman-manager` is here as a fallback GUI specifically for
      # classic PIN-code pairing (some Bluetooth keyboards) that simpler
      # panels sometimes don't prompt for correctly.
      services.blueman.enable = true;
    };
}
