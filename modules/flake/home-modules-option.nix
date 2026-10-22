# flake-parts bundles a declaration for `flake.nixosModules` (see its own
# modules/nixosModules.nix) which is why every `flake.nixosModules.<name> =
# ...` across this repo merges into one attrset without complaint. It does
# NOT know about `flake.homeModules` — that's our own dendritic-pattern
# convention, home-manager isn't part of flake-parts' core — so without this
# declaration, flake-parts falls back to treating `flake.homeModules` as a
# freeform, single-definition-only attribute. Every file under modules/home/
# defining a different `flake.homeModules.<name>` then collides as
# "the option `flake.homeModules' is defined multiple times", which (due to
# a separate quirk in how Nix pretty-prints that error for self-referential
# module values) actually surfaces as "infinite recursion encountered"
# instead of the real message.
{ lib, ... }:
{
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    description = ''
      Home Manager modules, keyed by name (this repo's convention — mirrors
      flake-parts' own `flake.nixosModules`).
    '';
  };
}
