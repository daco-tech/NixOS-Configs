# Pulls in NixOS/nixos-hardware's quirks module for exactly this laptop:
# correct TrackPoint device name/DPI, Intel CPU microcode + `common/pc/ssd`
# (fstrim), and general ThinkPad laptop bits (powertop-style tuning hooks,
# trackpoint scroll-emulation). See:
# https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/x1-extreme/gen4
{
  inputs,
  ...
}:
{
  flake.nixosModules.hw-x1-extreme-gen4 = {
    imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen4 ];
  };
}
