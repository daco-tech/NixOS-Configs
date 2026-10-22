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

        # Kubernetes CLI tooling. (kubecolor itself is pulled in below by
        # programs.kubecolor.enable, not listed here.)
        pkgs.kubectl
        pkgs.k9s # terminal UI for browsing/managing cluster resources
        pkgs.kubectx # adds `kubectx`/`kubens` for switching context/namespace
        pkgs.talosctl # CLI for Talos Linux clusters

        pkgs.rsync
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

      # Wraps kubectl for colorized output; enableAlias makes `kubectl`
      # itself resolve to kubecolor (see programs.zsh in
      # modules/home/shell.nix for enableZshIntegration's completion glue).
      programs.kubecolor = {
        enable = true;
        enableAlias = true;
        enableZshIntegration = true;
      };
    };
}
