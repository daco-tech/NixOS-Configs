# Combines the per-concern home-manager pieces (niri, noctalia, apps) into
# one profile a host can hand to `home-manager.users.<name>`. Add more
# `flake.homeModules.*` files next to this one as your setup grows — nothing
# here needs to change to pick them up, they just need to be added to the
# `imports` list below (or, in true dendritic spirit, split further so
# `hosts/<host>/default.nix` composes exactly the pieces it wants).
{ config, ... }:
{
  flake.homeModules.desktop-profile = {
    imports = [
      config.flake.homeModules.niri-user
      config.flake.homeModules.noctalia-user
      config.flake.homeModules.apps-user
      config.flake.homeModules.dev-tools-user
      config.flake.homeModules.mail-user
      config.flake.homeModules.shell-user
      config.flake.homeModules.ashell-user
      config.flake.homeModules.file-manager-user
    ];

    home.stateVersion = "25.05"; # do not bump casually — see home-manager release notes
  };
}
