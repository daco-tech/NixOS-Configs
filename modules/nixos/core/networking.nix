{
  flake.nixosModules.core-networking =
    { lib, pkgs, ... }:
    {
      # hostName is set per-host in hosts/<host>/default.nix via
      # `networking.hostName`; NetworkManager itself is already turned on by
      # noctalia's recommendedServices, but we set it explicitly here so this
      # module works even without noctalia.
      networking.networkmanager.enable = lib.mkDefault true;
      networking.firewall.enable = true;

      # Intel AX211/AX210 cards (used in this ThinkPad generation) are prone
      # to latency spikes and dropped connections with powersave on.
      networking.networkmanager.wifi.powersave = false;

      # Hidden SSIDs require directed probes when NetworkManager scans. Avoid
      # randomized scan MAC addresses, which prevent some access points from
      # responding to those probes.
      networking.networkmanager.wifi.scanRandMacAddress = false;

      # Day-to-day Wi-Fi (scan, connect, forget, enter a password) is meant
      # to happen in Noctalia's own Control Center panel — it talks to
      # NetworkManager over D-Bus directly and implements its own secret
      # agent (the password prompt), so nothing extra is needed for that.
      # `nm-connection-editor` is here as a fallback GUI for anything the
      # panel doesn't cover (hidden SSIDs, enterprise/802.1x Wi-Fi, static
      # IP config, VPN profiles); `nmtui`/`nmcli` (from the `networkmanager`
      # package, already installed as part of enabling the service above)
      # work from a terminal too.
      environment.systemPackages = [ pkgs.networkmanagerapplet ];
    };
}
