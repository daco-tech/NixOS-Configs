{
  flake.homeModules.apps-user =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.obsidian ];

      # Nothing in this config installed a browser before — NixOS ships none by
      # default. Firefox is the path of least resistance here: native Wayland,
      # and it talks to the GNOME xdg-desktop-portal already set up in
      # modules/nixos/desktop/niri.nix for file pickers and screen sharing.
      # Swap freely — `pkgs.chromium`, `pkgs.brave`, `pkgs.google-chrome`
      # (unfree, already allowed) all work; Chromium-family browsers want
      # `--ozone-platform-hint=auto` to run as Wayland rather than XWayland.
      programs.firefox.enable = true;

      # Auto-starts as a systemd --user service on `graphical-session.target`
      # (the same target niri/niri-session activates), so it comes up
      # minimized/tray on login rather than needing to be launched by hand.
      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
}
