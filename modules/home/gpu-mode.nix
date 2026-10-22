# Windows-Optimus-style GPU preference for hybrid graphics
# (modules/nixos/hardware/graphics-hybrid.nix): a persisted 3-way mode
# (auto/nvidia/intel) that decides what `gpu-launch` does with a command, not
# a system-wide GPU switch. niri itself always renders on the Intel iGPU
# (PRIME *offload*, not PRIME sync — see graphics-hybrid.nix) and nothing
# here changes that; only what newly-launched apps prefer changes, and only
# for launches that actually go through `gpu-launch`. No logout or reboot
# needed, mirroring Windows' NVIDIA Control Panel "preferred GPU" setting,
# which likewise only takes effect for apps started after the change.
#
# State lives in a plain file rather than an env var because niri (and any
# other already-running process) captures its environment once at startup —
# an external command can't mutate a sibling process's env after the fact,
# so anything that must react without a restart has to re-read state fresh
# on every launch instead.
{
  flake.homeModules.gpu-mode-user =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "gpu-mode";
          runtimeInputs = [ pkgs.libnotify ];
          text = ''
            state_file="$HOME/.local/state/gpu-mode"

            current() {
              if [ -f "$state_file" ]; then
                cat "$state_file"
              else
                echo auto
              fi
            }

            write_mode() {
              mkdir -p "$(dirname "$state_file")"
              printf '%s' "$1" > "$state_file"
              notify-send -a "GPU Mode" "GPU mode: $1" \
                "Apps launched from now on via gpu-launch (and the terminal keybind) will prefer $1. Already-running apps are unaffected."
            }

            case "''${1:-get}" in
              get)
                current
                ;;
              cycle)
                mode=$(current)
                case "$mode" in
                  auto) next=nvidia ;;
                  nvidia) next=intel ;;
                  *) next=auto ;;
                esac
                write_mode "$next"
                echo "$next"
                ;;
              set)
                mode="''${2:-}"
                case "$mode" in
                  auto | nvidia | intel) write_mode "$mode" ;;
                  *)
                    echo "usage: gpu-mode set {auto|nvidia|intel}" >&2
                    exit 1
                    ;;
                esac
                ;;
              *)
                echo "usage: gpu-mode {get|set <auto|nvidia|intel>|cycle}" >&2
                exit 1
                ;;
            esac
          '';
        })

        # Drop-in prefix for launching something under the current GPU mode,
        # e.g. `gpu-launch kitty`. "nvidia" defers to the `nvidia-offload`
        # wrapper (from hardware.nvidia.prime.offload.enableOffloadCmd in
        # graphics-hybrid.nix) rather than re-deriving its env vars here, so
        # this stays correct if that wrapper's behavior ever changes.
        # "intel" strips the offload vars defensively, in case the launched
        # program tries to opt itself onto the dGPU (e.g. its own NVIDIA
        # PRIME env settings).
        (pkgs.writeShellApplication {
          name = "gpu-launch";
          text = ''
            if [ "$#" -eq 0 ]; then
              echo "usage: gpu-launch <command> [args...]" >&2
              exit 1
            fi

            state_file="$HOME/.local/state/gpu-mode"
            mode=auto
            if [ -f "$state_file" ]; then
              mode=$(cat "$state_file")
            fi

            case "$mode" in
              nvidia)
                exec nvidia-offload "$@"
                ;;
              intel)
                exec env -u __NV_PRIME_RENDER_OFFLOAD -u __NV_PRIME_RENDER_OFFLOAD_PROVIDER \
                  -u __GLX_VENDOR_LIBRARY_NAME -u __VK_LAYER_NV_optimus "$@"
                ;;
              *)
                exec "$@"
                ;;
            esac
          '';
        })
      ];
    };
}
