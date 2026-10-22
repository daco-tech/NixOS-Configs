# ashell (https://github.com/MalpenZibo/ashell) — a wlr-layer-shell status
# bar, installed on request. It's built/documented for Hyprland but relies
# only on the standard wlr-layer-shell protocol, which niri also implements,
# so it should run — just don't expect Hyprland-specific bits (special
# workspaces, etc.) to do anything useful here.
#
# NOT auto-started: Noctalia Shell (modules/home/noctalia.nix) already draws
# its own top bar, and niri only reserves one layer-shell strip per edge —
# running both at once means two bars fighting over the same screen edge.
# Add `{ command = [ "ashell" ]; }` to niri's `spawn-at-startup`
# (modules/home/niri.nix) once you've decided how to avoid that overlap
# (e.g. disable Noctalia's bar, or only launch ashell manually to compare).
{
  flake.homeModules.ashell-user =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ashell ];

      # GPU launcher button: a real live-toggle of "which GPU the whole
      # session uses" isn't something NixOS/Wayland can do without a logout
      # (PRIME offload is fundamentally per-process), so this is the honest
      # version — click it, a fuzzel app picker pops up, and whatever you
      # pick launches on the NVIDIA dGPU via `nvidia-offload` (the wrapper
      # from hardware/graphics-hybrid.nix's `prime.offload.enableOffloadCmd`)
      # instead of the default Intel iGPU. Everything else in ashell is left
      # at its built-in defaults; only the right module group is overridden
      # to slot this button in.
      xdg.configFile."ashell/config.toml".text = ''
        [modules]
        right = [ "SystemInfo", [ "Tray", "GpuLauncher", "Settings" ] ]

        [[CustomModule]]
        name = "GpuLauncher"
        icon = "GPU"
        command = "fuzzel --launch-prefix=nvidia-offload --prompt='GPU: '"
      '';
    };
}
