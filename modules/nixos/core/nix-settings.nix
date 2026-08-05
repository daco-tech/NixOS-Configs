# flake.nixosModules.* is a plain community convention (also used by
# nixos-hardware itself): any dendritic file can add to it, and any other
# file can pull a piece in later via `config.flake.nixosModules.<name>`.
{
  flake.nixosModules.core-nix =
    { inputs, ... }:
    {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        # Lets `nixos-rebuild` etc. trust this flake's own substituters/caches
        # without prompting, e.g. niri.cachix.org.
        trusted-users = [
          "root"
          "@wheel"
        ];
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      # So `nix registry` / `nixos-rebuild --flake` resolve to this checkout's inputs.
      nix.registry.nixpkgs.flake = inputs.nixpkgs;

      nixpkgs.config.allowUnfree = true; # NVIDIA driver, etc.

      documentation.nixos.enable = false; # faster rebuilds; drop if you want `nixos-help`
    };
}
