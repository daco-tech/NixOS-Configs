# System-level half of Noctalia. `inputs.noctalia.nixosModules.default`
# already wires `programs.noctalia.package` to the flake's own build, so we
# only need to flip the switches. Per-user look-and-feel (theme, bar layout,
# monitor scale, etc.) lives in modules/home/noctalia.nix instead, since
# that's where Noctalia's own `settings` option is exposed.
{ inputs, ... }:
{
  flake.nixosModules.desktop-noctalia = {
    imports = [ inputs.noctalia.nixosModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true; # start as a user service on graphical-session.target (niri provides this)
      recommendedServices.enable = true; # NetworkManager, Bluetooth, UPower, power-profiles-daemon
    };
  };
}
