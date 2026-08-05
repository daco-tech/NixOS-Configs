{ inputs, ... }:
{
  flake.homeModules.noctalia-user = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      # Nix attrset -> TOML, written to ~/.config/noctalia/config.toml.
      # Fine-tune from Noctalia's own settings UI at runtime, or here for
      # something you want to survive a `home-manager switch`.
      # See: https://docs.noctalia.dev/v5/
      settings = {
        shell.font = "JetBrainsMono Nerd Font";
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
      };
    };
  };
}
