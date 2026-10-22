# The X1 Extreme Gen 4's power-button fingerprint sensor is a
# libfprint-supported match-on-chip device on most units.
#
# `security.pam.services.<name>.fprintAuth` defaults to
# `config.services.fprintd.enable` for *every* PAM service NixOS defines
# (login, sudo, su, polkit-1, and whatever PAM service name greetd
# registers) — so turning on fprintd already makes fingerprint the
# first-tried factor everywhere, including at the tuigreet login screen, for
# `sudo`, and for polkit's GUI auth prompts (package installs, mounting
# drives, etc. — `security.polkit.enable` is set in
# ../desktop/niri.nix, which is what registers the `polkit-1` PAM service).
# The lines below just make that explicit/discoverable instead of relying on
# the implicit default; flip any to `false` if you'd rather that one prompt
# for a password only.
#
# After install, enroll a finger as yourself (no sudo needed — fprintd asks
# polkit for consent):
#   fprintd-enroll
#   fprintd-verify   # test it
#
# `login` is deliberately NOT given fprintAuth (overriding the implicit
# default above), even though it's the PAM service for virtual console
# login: Noctalia's lock screen (../desktop/noctalia.nix) authenticates its
# password fallback against that exact same "login" PAM service, but drives
# the fingerprint reader itself directly over fprintd's D-Bus API rather
# than through PAM — the two can't both hold the sensor open at once. Noctalia's
# own source (src/shell/lockscreen/lock_screen.cpp) is explicit about this:
# "If fingerprint is enabled, strip pam_fprintd from [the login stack]:
# noctalia drives the reader itself over D-Bus and the two can't share the
# sensor." Turning fprintAuth on here would make the *first* unlock attempt
# after locking silently fight Noctalia's own reader claim. The tradeoff:
# switching to a bare virtual console (Ctrl+Alt+F2) still only accepts a
# password — a niche path compared to the lock screen.
{
  flake.nixosModules.hw-fingerprint = {
    services.fprintd.enable = true;

    security.pam.services.greetd.fprintAuth = true; # tuigreet login screen (boot)
    security.pam.services.login.fprintAuth = false; # see comment above — Noctalia owns this one
    security.pam.services.sudo.fprintAuth = true; # sudo in a terminal
    security.pam.services.polkit-1.fprintAuth = true; # GUI apps' auth prompts
  };
}
