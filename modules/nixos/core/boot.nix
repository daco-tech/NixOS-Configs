{
  flake.nixosModules.core-boot =
    { pkgs, ... }:
    {
      # systemd-boot instead of rEFInd: rEFInd's own ESP-scanning behavior
      # kept finding and booting leftover/foreign bootloader files on this
      # machine's disk (multiple past installs), landing back on the wrong
      # generation instead of the one this flake builds. systemd-boot writes
      # one explicit, unambiguous menu entry per generation and is what
      # already booted generation 1 reliably before this flake was ever
      # applied. Windows stays reachable via `extraEntries` below — no
      # os-prober, no ESP auto-scanning to go wrong.
      boot.loader.systemd-boot = {
        enable = true;
        extraEntries = {
          "windows.conf" = ''
            title Windows
            efi /EFI/Microsoft/Boot/bootmgfw.efi
          '';
        };
      };
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.timeout = 5;

      boot.loader.grub.enable = false;

      # Recent kernel for up-to-date Wayland/NVIDIA/Alder-Lake-P support.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.plymouth.enable = true;
      boot.consoleLogLevel = 3;
      boot.kernelParams = [
        "quiet"
        # Required for driver >=555 to hand the framebuffer off to Wayland
        # compositors cleanly.
        "nvidia_drm.fbdev=1"
      ];

      boot.tmp.cleanOnBoot = true;
    };
}
