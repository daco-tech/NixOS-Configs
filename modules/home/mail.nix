# Thunderbird: single app for mail plus contacts/calendar. Calendar
# (formerly the Lightning add-on) and CardDAV/CalDAV address books are
# built into modern Thunderbird — no extra packages or GNOME Online
# Accounts plumbing needed.
#
# Add accounts by hand:
#   - Mail: Thunderbird auto-detects IMAP settings for Gmail etc. via
#     Account Settings > Account Actions > Add Mail Account.
#   - iCloud calendar/contacts: Account Settings > Calendar > Add Calendar
#     > On the Network, and Address Book > New Address Book > Remote
#     Address Book (CardDAV), pointing at:
#       https://caldav.icloud.com   (calendar)
#       https://contacts.icloud.com (contacts)
#     using an app-specific password from appleid.apple.com (your normal
#     Apple ID password won't work, especially with 2FA/Advanced Data
#     Protection on).
{
  flake.homeModules.mail-user =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.thunderbird ];
    };
}
