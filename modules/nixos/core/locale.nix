{
  flake.nixosModules.core-locale = {
    # CHANGE ME if this isn't right — inferred from your email's .pt domain.
    time.timeZone = "Europe/Lisbon";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_TIME = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
    };

    console.keyMap = "pt-latin1"; # TTY console + tuigreet login screen
    services.xserver.xkb = {
      layout = "pt";
      variant = "";
    };
  };
}
