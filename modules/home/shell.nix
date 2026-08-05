# Terminal look-and-feel + shell/CLI tooling. `programs.foot.enable` itself
# lives in modules/home/niri.nix (it's niri's terminal keybind); the theme
# here is Catppuccin Mocha to match Noctalia (modules/home/noctalia.nix).
{
  flake.homeModules.shell-user =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.pydf # colourized `df`
        pkgs.htop
        # GPU monitoring (nvtop) is already installed system-wide in
        # modules/nixos/hardware/graphics-hybrid.nix, since it needs to see
        # the NVIDIA driver regardless of which user runs it.
      ];

      programs.foot.settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          pad = "12x12";
        };
        colors = {
          background = "1e1e2e";
          foreground = "cdd6f4";
          regular0 = "45475a";
          regular1 = "f38ba8";
          regular2 = "a6e3a1";
          regular3 = "f9e2af";
          regular4 = "89b4fa";
          regular5 = "f5c2e7";
          regular6 = "94e2d5";
          regular7 = "bac2de";
          bright0 = "585b70";
          bright1 = "f38ba8";
          bright2 = "a6e3a1";
          bright3 = "f9e2af";
          bright4 = "89b4fa";
          bright5 = "f5c2e7";
          bright6 = "94e2d5";
          bright7 = "a6adc8";
        };
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        history.size = 10000;

        shellAliases = {
          ll = "ls -lah";
          gpu = "nvtop";
        };

        oh-my-zsh = {
          enable = true;
          theme = "agnoster"; # powerline-style; needs a Nerd Font, already the default everywhere (core/fonts.nix)
          plugins = [
            "git"
            "sudo"
            "history"
            "colored-man-pages"
            "command-not-found"
          ];
        };
      };

      # SSH: pairs with `programs.ssh.startAgent` at the system level
      # (modules/nixos/core/shell.nix) — unlocked keys stay cached in the
      # agent for the session instead of re-prompting every use.
      programs.ssh = {
        enable = true;
        settings."*".AddKeysToAgent = "yes";
      };
    };
}
