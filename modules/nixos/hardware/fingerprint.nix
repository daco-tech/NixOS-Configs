# The X1 Extreme Gen 4's power-button fingerprint sensor is a
# libfprint-supported match-on-chip device on most units.
#
# `security.pam.services.<name>.fprintAuth` defaults to
# `config.services.fprintd.enable` for *every* PAM service NixOS defines
# (login, sudo, su, and whatever PAM service name greetd registers) — so
# turning on fprintd already makes fingerprint the first-tried factor
# everywhere, including at the tuigreet login screen and for `sudo`. The two
# lines below just make that explicit/discoverable instead of relying on the
# implicit default; flip either to `false` if you'd rather that one prompt
# for a password only.
#
# After install, enroll a finger as yourself (no sudo needed — fprintd asks
# polkit for consent):
#   fprintd-enroll
#   fprintd-verify   # test it
{
  flake.nixosModules.hw-fingerprint = {
    services.fprintd.enable = true;

    security.pam.services.greetd.fprintAuth = true; # tuigreet login screen
    security.pam.services.login.fprintAuth = true; # virtual console login
    security.pam.services.sudo.fprintAuth = true;
  };
}
