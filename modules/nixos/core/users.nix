{
  flake.nixosModules.core-users =
    { pkgs, ... }:
    {
      # CHANGE ME: full name and initial password.
      # `initialPassword` only takes effect the very first time the account is
      # created (it never overwrites a password you've since changed) — run
      # `passwd` right after first login to set a real one. You'll still want
      # a real password even with fingerprint login enabled (see
      # ../hardware/fingerprint.nix) — it's required whenever the sensor
      # can't read a finger, and for the initial login before you've enrolled.
      users.users.dcosta = {
        isNormalUser = true;
        description = "Daniel Costa";
        initialPassword = "changeme";
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
