# The one place that assembles a bootable system: every `flake.nixosModules.*`
# built up by the other dendritic files, plus this host's own hardware scan
# and identity. Adding a second machine later means adding a second file
# here (e.g. `desktop.nix`) — flake.nix itself never changes.
{
  inputs,
  config,
  ...
}:
{
  flake.nixosConfigurations.x1-extreme = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Real hardware scan, from `nixos-generate-config` run on this actual
      # laptop. See ../../../hosts/x1-extreme/hardware-configuration.nix
      ../../../hosts/x1-extreme/hardware-configuration.nix

      config.flake.nixosModules.core-nix
      config.flake.nixosModules.core-boot
      config.flake.nixosModules.core-networking
      config.flake.nixosModules.core-locale
      config.flake.nixosModules.core-users
      config.flake.nixosModules.core-fonts
      config.flake.nixosModules.core-shell

      config.flake.nixosModules.hw-x1-extreme-gen4
      config.flake.nixosModules.hw-graphics-hybrid
      config.flake.nixosModules.hw-audio-bluetooth
      config.flake.nixosModules.hw-power
      config.flake.nixosModules.hw-fingerprint
      config.flake.nixosModules.hw-removable-media

      config.flake.nixosModules.desktop-niri
      config.flake.nixosModules.desktop-noctalia
      config.flake.nixosModules.desktop-greetd
      config.flake.nixosModules.desktop-pim

      inputs.home-manager.nixosModules.home-manager
      {
        networking.hostName = "daco-book";
        system.stateVersion = "26.05"; # set once at install time, then never changed

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          users.dcosta = config.flake.homeModules.desktop-profile;
        };
      }
    ];
  };
}
