# Two network printers on the LAN, both "auto discoverable" but declared
# explicitly here (rather than left to interactive `system-config-printer`
# setup) so a fresh install already has working, named print queues.
#
# Epson ET-3850: fully supports IPP Everywhere (driverless) — CUPS's
# built-in "everywhere" PPD generator successfully polls it for capabilities
# (duplex, color modes, paper sizes), confirmed with
# `nix shell nixpkgs#cups-filters -c driverless ipp://epson.sc.network:631/ipp/print`.
# No vendor driver package needed.
#
# Canon TS3400: advertises an IPP port but doesn't answer enough of the
# get-printer-attributes exchange for CUPS to build a driverless PPD ("Could
# not poll sufficient capability info from the printer via IPP!"), so it
# needs Canon's own driver instead — `cnijfilter2` lists the TS3400 series
# — talking raw JetDirect (port 9100) rather than IPP.
#
# Both printers have stable DNS hostnames on the LAN (not just mDNS
# `.local` names), found via `nmap -p 631,9100,80 --open <subnet>` and
# confirmed with `getent hosts`, so deviceUri below won't break if DHCP
# reassigns their IPs.
{
  flake.nixosModules.hw-printing =
    { pkgs, ... }:
    {
      services.printing = {
        enable = true;
        drivers = [ pkgs.cnijfilter2 ]; # Canon TS3400; Epson needs no vendor driver (driverless)
      };

      # mDNS/DNS-SD lookups (CUPS' avahi-based browsing, and how apps'
      # print dialogs can list network printers directly).
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # These hostnames only resolve via the router's DHCP-lease-based DNS
      # while the printer is actually powered on, so `lpadmin` legitimately
      # fails (exit 1) whenever a printer is off — e.g. laptop away from
      # home, or a printer asleep. Treat that as a non-fatal, retry-next-time
      # outcome rather than a "failed" unit, so it doesn't turn every
      # `nixos-rebuild switch` red (and non-zero-exit) just because a
      # printer happens to be unreachable.
      systemd.services.ensure-printers.serviceConfig.SuccessExitStatus = [ 1 ];

      hardware.printers = {
        ensurePrinters = [
          {
            name = "Epson_ET_3850";
            description = "Epson ET-3850";
            location = "Home";
            deviceUri = "ipp://epson.sc.network:631/ipp/print";
            model = "everywhere";
          }
          {
            name = "Canon_TS3400";
            description = "Canon TS3400";
            location = "Home";
            deviceUri = "socket://canon.sc.network:9100";
            model = "canonts3400.ppd";
          }
        ];
        ensureDefaultPrinter = "Epson_ET_3850";
      };
    };
}
