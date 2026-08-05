# Personal-info-management plumbing for Evolution (mail/contacts/calendar,
# installed per-user in modules/home/mail.nix). GNOME Online Accounts gives
# it a native "iCloud" provider — add the account via
# gnome-control-center's Online Accounts panel, using an app-specific
# password from appleid.apple.com (your normal Apple ID password won't work
# for CalDAV/CardDAV, especially with 2FA/Advanced Data Protection on).
#
# GOA has a history of being flaky specifically on NixOS for iCloud. If the
# account doesn't sync, skip GOA entirely and add the calendar/address book
# directly inside Evolution instead: File > New > Calendar / Address Book,
# type "On the Web", and point it at:
#   https://caldav.icloud.com   (calendar)
#   https://contacts.icloud.com (contacts)
# using the same app-specific password.
{
  flake.nixosModules.desktop-pim =
    { pkgs, ... }:
    {
      services.gnome.evolution-data-server.enable = true;
      services.gnome.gnome-online-accounts.enable = true;

      # Provides the "Online Accounts" settings panel used to add the
      # iCloud account. Runs standalone fine outside a full GNOME session.
      environment.systemPackages = [ pkgs.gnome-control-center ];
    };
}
