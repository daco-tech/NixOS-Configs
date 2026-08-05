# `programs.niri.settings` is already available in home-manager scope
# without any extra import: niri's `nixosModules.niri` (imported at system
# level in modules/nixos/desktop/niri.nix) auto-registers its
# `homeModules.config` as a home-manager shared module once home-manager
# runs as a NixOS module — see niri-flake's docs.md ("homeModules.config").
#
# Noctalia can NOT register its own global shortcuts: it's a wlr-layer-shell
# client, and Wayland gives clients no way to grab keys the compositor hasn't
# routed to them. Every Noctalia panel (launcher included) has to be opened by
# the compositor calling Noctalia's IPC — hence the `noctalia msg ...` binds
# below. Without them the launcher exists but is unreachable.
#
# `noctalia msg` is the v5 CLI; v4 used `noctalia-shell ipc call <target>
# <method>`. If a bind does nothing, run `noctalia msg --help` on the machine
# to see what the version you actually built accepts.
# See: https://docs.noctalia.dev/v5/compositor-settings/niri/
{
  flake.homeModules.niri-user = {
    home.packages = [ ]; # add per-user extras here later

    programs.foot.enable = true; # terminal (Mod+Return)
    programs.fuzzel.enable = true; # lightweight fallback launcher (Mod+D)

    programs.niri.settings = {
      input = {
        keyboard.xkb.layout = "pt";
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      # X1 Extreme Gen 4's 16:10 panel is high-DPI on the UHD/QHD+ config —
      # tune to 1.0 if you have the FHD panel option.
      outputs."eDP-1".scale = 1.5;

      binds = {
        "Mod+Return".action.spawn = "foot";

        # Noctalia's panels. List form (rather than `spawn-sh "..."`) so no
        # shell is involved and no quoting can go wrong — none of these need one.
        "Mod+Space".action.spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "launcher"
        ];
        "Mod+S".action.spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "control-center"
        ];
        "Mod+Comma".action.spawn = [
          "noctalia"
          "msg"
          "settings-toggle"
        ];
        "Alt+Tab".action.spawn = [
          "noctalia"
          "msg"
          "window-switcher"
        ];

        # Kept as a fallback: works even if Noctalia's service is down, and is
        # the quickest way to tell "launcher unreachable" apart from
        # "Noctalia isn't running at all".
        "Mod+D".action.spawn = "fuzzel";

        "Mod+Q".action.close-window = { };
        "Mod+Shift+E".action.quit = { };
        "Mod+Left".action.focus-column-left = { };
        "Mod+Right".action.focus-column-right = { };
        "Mod+Shift+Left".action.move-column-left = { };
        "Mod+Shift+Right".action.move-column-right = { };
        "Mod+F".action.maximize-column = { };
        "Mod+Shift+F".action.fullscreen-window = { };
        "Print".action.screenshot = { };
      };

      # Verify against niri-flake's docs.md if this doesn't take effect —
      # `spawn-at-startup` mirrors the KDL node `spawn-at-startup "cmd"`.
      spawn-at-startup = [
        { command = [ "xwayland-satellite" ]; }
      ];
    };
  };
}
