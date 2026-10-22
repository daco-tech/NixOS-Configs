{ inputs, ... }:
{
  flake.nixosModules.desktop-niri =
    { pkgs, ... }:
    {
      imports = [ inputs.niri.nixosModules.niri ];

      programs.niri.enable = true;

      # Niri speaks the same screencast/remote-desktop D-Bus interface as
      # GNOME Shell (Mutter), so xdg-desktop-portal-gnome — not the wlroots
      # portal — is what makes screen sharing work.
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        config.niri.default = [
          "gnome"
          "gtk"
        ];
      };

      # Small polish items niri doesn't manage itself.
      programs.dconf.enable = true; # needed by xdg-desktop-portal-gnome + GTK apps
      services.gnome.gnome-keyring.enable = true;
      security.polkit.enable = true;
      services.gvfs.enable = true; # trash/mount support in file pickers

      # X11 app compatibility (niri is Wayland-only natively). Launch it at
      # session start via home-manager's `spawn-at-startup` (see
      # modules/home/niri.nix).
      environment.systemPackages = [ pkgs.xwayland-satellite ];
    };
}
