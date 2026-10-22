{
  flake.homeModules.apps-user =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.obsidian
        pkgs.zapzap # WhatsApp desktop client (PyQt6 + WebEngine wrapper around WhatsApp Web), with tray icon and native notifications
        pkgs.onlyoffice-desktopeditors # office suite (Word/Excel/PowerPoint-compatible), AGPL3+ so no unfree allowlisting needed
        pkgs.drawio # diagramming app; file-manager.nix wires it up as the default handler for .drawio files
        pkgs.gnome-calculator
        pkgs.mqttx # graphical MQTT 5 client for browsing topics and live messages
      ];

      # Nothing in this config installed a browser before — NixOS ships none by
      # default. Firefox is the path of least resistance here: native Wayland,
      # and it talks to the GNOME xdg-desktop-portal already set up in
      # modules/nixos/desktop/niri.nix for file pickers and screen sharing.
      # Swap freely — `pkgs.chromium`, `pkgs.brave`, `pkgs.google-chrome`
      # (unfree, already allowed) all work; Chromium-family browsers want
      # `--ozone-platform-hint=auto` to run as Wayland rather than XWayland.
      programs.firefox.enable = true;
      programs.firefox.configPath = ".mozilla/firefox"; # pin legacy path; profile predates the XDG default and hasn't been migrated

      # Auto-starts as a systemd --user service on `graphical-session.target`
      # (the same target niri/niri-session activates), so it comes up
      # minimized/tray on login rather than needing to be launched by hand.
      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
}
