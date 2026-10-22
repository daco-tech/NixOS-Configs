# Terminal look-and-feel + shell/CLI tooling. `programs.kitty.enable` itself
# lives in modules/home/niri.nix (it's niri's terminal keybind); the theme
# here is Catppuccin Mocha to match Noctalia (modules/home/noctalia.nix).
{
  flake.homeModules.shell-user =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.pydf # colourized `df`
        pkgs.htop
        # GPU monitoring (nvtop) is already installed system-wide in
        # modules/nixos/hardware/graphics-hybrid.nix, since it needs to see
        # the NVIDIA driver regardless of which user runs it.
      ];

      # NixApps (../../../NixApps/, see its CONTEXT.md): `sh enable.sh
      # <App>` links each enabled app's binaries into
      # $XDG_RUNTIME_DIR/nixapps/bin. XDG_RUNTIME_DIR is tmpfs, wiped every
      # logout/reboot, which is the whole mechanism that makes NixApps
      # tools disappear on restart without any extra service/timer — this
      # PATH entry just needs to always be present, whether or not
      # anything is currently linked into it.
      home.sessionPath = [ "$XDG_RUNTIME_DIR/nixapps/bin" ];

      programs.kitty = {
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 11;
        };
        settings = {
          window_padding_width = 12;
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          color0 = "#45475a";
          color1 = "#f38ba8";
          color2 = "#a6e3a1";
          color3 = "#f9e2af";
          color4 = "#89b4fa";
          color5 = "#f5c2e7";
          color6 = "#94e2d5";
          color7 = "#bac2de";
          color8 = "#585b70";
          color9 = "#f38ba8";
          color10 = "#a6e3a1";
          color11 = "#f9e2af";
          color12 = "#89b4fa";
          color13 = "#f5c2e7";
          color14 = "#94e2d5";
          color15 = "#a6adc8";
        };
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        history.size = 10000;

        shellAliases = {
          ll = "ls -lah";
          gpu = "nvtop";
          # zsh expands aliases recursively, so this also picks up the
          # kubectl -> kubecolor alias set by programs.kubecolor.enableAlias
          # in modules/home/dev-tools.nix.
          k = "kubectl";
        };

        oh-my-zsh = {
          enable = true;
          theme = "agnoster"; # powerline-style; needs a Nerd Font, already the default everywhere (core/fonts.nix)
          plugins = [
            "git"
            "sudo"
            "history"
            "colored-man-pages"
            "command-not-found"
          ];
        };
      };

      # SSH: pairs with `programs.ssh.startAgent` at the system level
      # (modules/nixos/core/shell.nix) — unlocked keys stay cached in the
      # agent for the session instead of re-prompting every use.
      #
      # The private key itself (~/.ssh/id_rsa) and known_hosts are NOT
      # declared here — they're runtime secrets/state, not config, so they
      # don't belong in the world-readable Nix store or git history. They're
      # copied directly into $HOME instead (see apply.sh / task notes).
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false; # HM's implicit `Host *` defaults are deprecated; set them explicitly below instead
        settings."*".AddKeysToAgent = "yes";
        settings."github.com" = {
          HostName = "ssh.github.com";
          Port = 443; # routes over 443 for networks that block outbound 22
        };
      };

      # Nano syntax highlighting: pkgs.nanorc bundles the same upstream
      # scopatz/nanorc file set (one .nanorc per language) that used to be
      # copied by hand into ~/.nano/ — nano's `include` directive accepts a
      # glob, so one line pulls in all of them instead of one include per
      # language.
      home.file.".nanorc".text = ''
        set titlecolor red,yellow
        set autoindent
        set linenumbers

        include "${pkgs.nanorc}/share/*.nanorc"
      '';

      # Tmux: plugins are pulled from nixpkgs (pkgs.tmuxPlugins) rather than
      # vendored as TPM git checkouts under ~/.tmux/plugins — declarative and
      # doesn't need TPM's install-on-first-run step.
      programs.tmux = {
        enable = true;
        prefix = "C-a";
        mouse = true;
        terminal = "screen-256color";
        plugins = with pkgs.tmuxPlugins; [
          prefix-highlight
          dracula
          resurrect
          continuum
          vim-tmux-navigator
        ];
        extraConfig = ''
          # split panes using | and -
          bind \ split-window -h
          bind - split-window -v
          unbind '"'
          unbind %

          # switch panes using Alt-arrow without prefix
          bind -n M-Left select-pane -L
          bind -n M-Right select-pane -R
          bind -n M-Up select-pane -U
          bind -n M-Down select-pane -D

          set -g status-right '#{prefix_highlight} | %a %Y-%m-%d %H:%M'

          # Dracula theme
          set -g @dracula-show-fahrenheit false
          set -g @dracula-show-powerline true
          set -g @dracula-show-network false
          set -g @dracula-show-left-icon session
          set -g @dracula-cpu-usage true
          set -g @dracula-ram-usage true
          set -g @dracula-day-month true
          set -g @dracula-military-time true
          set -g @dracula-show-flags true
          set -g @dracula-fixed-location Porto
          set -g @dracula-plugins "weather"

          # tmux-resurrect / tmux-continuum
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @continuum-restore 'on'
        '';
      };
    };
}
