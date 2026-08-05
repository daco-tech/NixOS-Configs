# Intel Iris Xe (iGPU) + NVIDIA RTX 3050 Ti (dGPU) hybrid graphics, using
# PRIME offload: the NVIDIA GPU stays powered off until something is
# explicitly launched on it (`nvidia-offload <cmd>`), which is what you want
# on battery. Niri itself always runs on the Intel iGPU.
#
# ACTION REQUIRED: `intelBusId` / `nvidiaBusId` below are the values seen on
# most X1 Extreme Gen 4 units, but PCI bus IDs can differ by board revision.
# After booting the installer, confirm with:
#   lspci | grep -E "VGA|3D"
# and adjust the two `busId` strings if yours differ.
{
  flake.nixosModules.hw-graphics-hybrid =
    { config, pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true; # Steam/Proton, Wine, etc.
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true; # allows the dGPU to fully power off when idle
        open = true; # Ampere (RTX 30-series) is supported by the open kernel module
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true; # provides the `nvidia-offload` wrapper
          };
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      environment.systemPackages = [ pkgs.nvtopPackages.full ];
    };
}
