# claude-code is unfree (Anthropic's license) — already covered by the
# global `nixpkgs.config.allowUnfree = true` set in
# modules/nixos/core/nix-settings.nix, so nothing extra needed here.
#
# opencode is installed from nixpkgs rather than its own npm/curl installer
# on purpose: prebuilt binaries fetched outside Nix commonly fail on NixOS
# with "could not start dynamically linked executable" since there's no
# FHS-standard dynamic linker path — the nixpkgs build patches that, so it
# just works.
{
  flake.homeModules.dev-tools-user =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.vscode
        pkgs.claude-code
        pkgs.opencode
      ];

      programs.git = {
        enable = true;
        settings = {
          # CHANGE ME if this isn't right.
          user.name = "Daniel Costa";
          user.email = "git@danielcosta.pt";
          init.defaultBranch = "main";
        };
      };

      programs.gh = {
        enable = true;
        settings.git_protocol = "https";
      };
    };
}
