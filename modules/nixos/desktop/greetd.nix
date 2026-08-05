# greetd + tuigreet as the login manager, launching niri via the
# `niri-session` wrapper (sets up the systemd user session/target that
# Noctalia's systemd service and xdg-desktop-portal rely on).
{
  flake.nixosModules.desktop-greetd =
    { config, pkgs, ... }:
    {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd ${config.programs.niri.package}/bin/niri-session";
          user = "greeter";
        };
      };

      # Avoid the double-login-manager trap.
      services.xserver.enable = false;
      services.displayManager.gdm.enable = false;
      services.displayManager.sddm.enable = false;
    };
}
