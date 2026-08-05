# Evolution: single app for mail (add your Gmail IMAP account directly in
# Evolution, or via GOA's Google provider) plus contacts/calendar (from
# iCloud, via GOA — see modules/nixos/desktop/pim.nix for setup + the
# CalDAV/CardDAV fallback if GOA misbehaves).
{
  flake.homeModules.mail-user =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.evolution ];
    };
}
