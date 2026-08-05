# Dendritic root settings: every other file under ./modules is auto-imported
# by `import-tree` in flake.nix and contributes to this same flake-parts
# config. This file just declares the systems we build for and how `pkgs`
# is constructed for perSystem outputs (devShells, packages, etc.).
{ inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true; # required for the NVIDIA driver
      };
    };
}
