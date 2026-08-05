{
  flake.nixosModules.core-fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono # used by Noctalia's bar/UI by default
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
      ];

      fonts.fontconfig.defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
}
