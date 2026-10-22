{
  flake.nixosModules.core-users =
    { pkgs, ... }:
    {
      # Set the password interactively before enabling this configuration on a
      # new installation. Never commit an initial password to this repository.
      users.users.dcosta = {
        isNormalUser = true;
        description = "Daniel Costa";
        shell = pkgs.zsh; # requires programs.zsh.enable (../core/shell.nix)
        extraGroups = [
          "wheel" # sudo
          "networkmanager"
          "video" # brightness control
          "audio"
          "input"
        ];
      };

      security.sudo.wheelNeedsPassword = true;
    };
}
