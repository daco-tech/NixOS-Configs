# Hibernate on critical battery. Plain suspend-to-RAM still draws a trickle
# of power, so a laptop left suspended and unplugged for long enough can
# still die and lose everything; hibernating writes RAM to disk and powers
# off completely, so the session survives no matter how long it sits
# unplugged, and comes back exactly as it was on the next boot.
#
# Needs a swapfile at least as big as physical RAM (62GiB on this machine)
# for the kernel to fit the whole memory image; `resume_offset` is the
# swapfile's physical location on disk and can only be computed with
# `filefrag` *after* /swapfile actually exists (see README.md for the
# two-step apply process this requires).
{
  flake.nixosModules.hw-hibernate =
    { lib, ... }:
    {
      swapDevices = [
        {
          device = "/swapfile";
          size = 71680; # 70GiB, > 62GiB RAM
        }
      ];

      boot.resumeDevice = "/dev/disk/by-label/NIXROOT";

      # Set after the first apply, once /swapfile exists — see README.md.
      boot.kernelParams = lib.mkAfter [
        # "resume_offset=<value from: sudo filefrag -v /swapfile>"
      ];

      # UPower is what actually watches the battery percentage and decides
      # when to act; power-profiles-daemon/logind don't see the percentage.
      services.upower = {
        enable = true;
        percentageLow = 15;
        percentageCritical = 5;
        percentageAction = 3;
        criticalPowerAction = "Hibernate";
      };
    };
}
