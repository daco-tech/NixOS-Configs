# Nautilus (GNOME Files) — picked over a lighter tiling-WM-standard option
# like Thunar because this setup already leans on GNOME plumbing
# (gnome-keyring, gvfs — see modules/nixos/desktop/niri.nix), so it
# integrates without adding a second toolkit's worth of dependencies.
# Automounting a USB drive (NTFS or FAT32 — see
# modules/nixos/hardware/removable-media.nix) is as simple as clicking it
# in the sidebar; right-click -> Eject before pulling it out.
#
# Papers is the same reasoning applied to PDFs: GNOME's GTK4/libadwaita
# document viewer (Evince's actively-developed successor), so it matches
# Nautilus visually and needs no extra toolkit. Opening a PDF from Nautilus,
# a browser download, or `xdg-open foo.pdf` in a terminal all land here.
{
  flake.homeModules.file-manager-user =
    { pkgs, config, ... }:
    {
      home.packages = [
        pkgs.nautilus
        pkgs.papers
        # GNOME's GTK4/libadwaita image viewer (formerly "Image Viewer",
        # Eye of GNOME's successor) — same reasoning as Papers above: matches
        # Nautilus/Papers visually, no extra toolkit. Without a registered
        # default, double-clicking a .jpg/.png in Nautilus or opening one
        # from a browser download has no GUI handler on niri (see the
        # `xdg.mimeApps` comment below) and fails instead of just opening.
        pkgs.loupe
        # drawio's .desktop file (see apps.nix) declares
        # MimeType=application/vnd.jgraph.mxfile, but the package ships no
        # shared-mime-info data telling the system that a *.drawio file
        # actually *is* that mimetype — upstream .deb/.rpm builds carry this
        # glob separately and nixpkgs doesn't package it. Without it,
        # Nautilus has no mimetype to look up a default handler for and
        # shows "no application" instead of open-with-drawio.
        # xdg.mime.enable (home-manager default on Linux) merges any
        # package's share/mime/packages/*.xml into the profile and reruns
        # update-mime-database, so dropping this in home.packages is enough
        # to register the glob.
        (pkgs.writeTextDir "share/mime/packages/drawio-mimetype.xml" ''
          <?xml version="1.0" encoding="UTF-8"?>
          <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
            <mime-type type="application/vnd.jgraph.mxfile">
              <comment>draw.io diagram</comment>
              <glob pattern="*.drawio"/>
              <glob pattern="*.dio"/>
            </mime-type>
          </mime-info>
        '')
      ];

      # niri ships no icon theme at all — only the empty "hicolor" fallback
      # spec — so every file in Nautilus rendered the same generic blank
      # icon regardless of type. Papirus gives each mimetype (docx, xlsx,
      # pptx, pdf, etc.) a distinct, colorful icon so file types are
      # recognizable at a glance; `gtk.enable` is required for
      # `gtk.iconTheme` to take effect (writes gtk-3.0/gtk-4.0 settings.ini
      # and the matching dconf key that GTK/libadwaita apps read).
      #
      # Papirus-Dark (rather than plain Papirus) re-tints the chrome icons
      # — not just folder colors — for a dark surrounding UI, matching the
      # Catppuccin Mocha theme below and Noctalia's own Catppuccin bar
      # (modules/home/noctalia.nix).
      #
      # `gtk.theme.package` covers both GTK versions: home-manager themes
      # GTK3 chrome the classic way (gtk-theme name + settings.ini), and
      # separately auto-@imports this same theme's gtk-4.0/gtk.css into
      # ~/.config/gtk-4.0/gtk.css — which is how Nautilus and Papers (both
      # GTK4/libadwaita) end up Catppuccin-colored too, since GTK4 dropped
      # theme-name selection but still loads that one user CSS file.
      # `color-scheme = prefer-dark` below is what keeps everything the
      # theme's CSS doesn't touch (text/icon named colors, window-control
      # symbols) in the dark variant rather than defaulting light.
      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        theme = {
          package = pkgs.catppuccin-gtk.override {
            variant = "mocha";
            accents = [ "mauve" ];
          };
          name = "catppuccin-mocha-mauve-standard";
        };
        # home-manager 26.05+ defaults gtk.gtk4.theme to null instead of
        # inheriting gtk.theme — opt back into inheriting it (the pre-26.05
        # behavior) since that's what actually gets this theme's
        # gtk-4.0/gtk.css imported for Nautilus/Papers, see below.
        gtk4.theme = config.gtk.theme;
        # Catppuccin's own gtk-4.0/gtk.css (imported above) sets an opaque
        # background, so transparency needs its own rule appended after it
        # — later same-specificity rule wins the cascade — scoped to
        # Nautilus's window class so it doesn't also hit Papers. niri does
        # no compositor-side blur of surfaces — unlike Hyprland/KWin — so
        # this reads as a flat tint over whatever is behind the window
        # (usually just the wallpaper, since niri tiles rather than stacks
        # windows), not frosted glass. Kept high (90-95% opaque) so text
        # stays legible without a blur pass behind it.
        gtk4.extraCss = ''
          .nautilus-window {
            background-color: alpha(@window_bg_color, 0.9);
          }
          .nautilus-window .view {
            background-color: alpha(@view_bg_color, 0.95);
          }
          .nautilus-window headerbar,
          .nautilus-window .sidebar-pane {
            background-color: alpha(@headerbar_bg_color, 0.85);
          }
        '';
      };

      # List view (rather than the icon-grid default) puts a "Type" column
      # next to each file, so what a Papirus icon implies is also spelled
      # out in text; sorting by modification time, newest first, surfaces
      # what you were just working on instead of alphabetical order.
      dconf.settings = {
        # Belongs with `gtk.theme` above — see the comment there for why
        # both this and the theme package are needed for a fully dark
        # Nautilus/Papers. accent-color's value is constrained to a fixed
        # GNOME palette
        # (blue/teal/green/yellow/orange/red/pink/purple/slate) — "purple"
        # is the closest match to the Catppuccin Mocha "mauve" accent used
        # for the GTK3 theme and Noctalia's bar.
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "purple";
        };
        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          default-sort-order = "mtime";
          default-sort-in-reverse-order = true;
        };
        "org/gnome/nautilus/list-view" = {
          default-visible-columns = [
            "name"
            "size"
            "type"
            "date_modified"
          ];
        };
      };

      # Without explicit defaults, neither `inode/directory` nor
      # `application/pdf` has a registered handler (niri isn't a DE that
      # GTK/xdg-utils auto-detects the way GNOME/KDE sessions are). Apps
      # that ask the desktop to open a folder or file via
      # xdg-open/QDesktopServices — e.g. Nextcloud client's "Open folder"
      # action, or a browser's "Open" on a downloaded PDF — then fail to
      # resolve a GUI handler and fall back to dropping the user into a
      # terminal instead.
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "org.gnome.Nautilus.desktop";
          "application/pdf" = "org.gnome.Papers.desktop";
          # Common image formats -> Loupe. mimeapps.list has no wildcard
          # syntax ("image/*" isn't valid), so each type loupe's own
          # MimeType= list declares needs its own line here; this covers the
          # ones actually likely to show up (photos, screenshots, web
          # images, icons) rather than mirroring its full list verbatim.
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "image/bmp" = "org.gnome.Loupe.desktop";
          "image/tiff" = "org.gnome.Loupe.desktop";
          "image/svg+xml" = "org.gnome.Loupe.desktop";
          "image/avif" = "org.gnome.Loupe.desktop";
          "image/heic" = "org.gnome.Loupe.desktop";
          # Same reasoning as above — OnlyOffice's .desktop file declares all
          # of these in its own `MimeType=` list, but niri never asks GTK to
          # pick a default from that, so Nautilus shows "no application" for
          # doc/xls/ppt without an explicit entry per type here.
          "application/msword" = "onlyoffice-desktopeditors.desktop"; # .doc
          "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop"; # .xls
          "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop"; # .ppt
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            "onlyoffice-desktopeditors.desktop"; # .docx
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
            "onlyoffice-desktopeditors.desktop"; # .xlsx
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
            "onlyoffice-desktopeditors.desktop"; # .pptx
          # .drawio / .dio — mimetype registered above since drawio itself
          # doesn't ship the shared-mime-info glob for it.
          "application/vnd.jgraph.mxfile" = "drawio.desktop";
          # 3D printing: .stl / .3mf models and .gcode toolpaths (see
          # cura.nix) — these globs are already registered by
          # shared-mime-info, just need a default handler pointed at them so
          # Nautilus and browser downloads open straight into Cura.
          "model/stl" = "cura.desktop";
          "model/3mf" = "cura.desktop";
          "text/x.gcode" = "cura.desktop";
          "text/x-gcode-gx" = "cura.desktop";
          # Pre-existing entry from the `claude` CLI self-registering as a
          # URL handler; folded in here so home-manager can manage the
          # whole file — it otherwise refuses to overwrite a mimeapps.list
          # it doesn't own.
          "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
        };
      };
      xdg.configFile."mimeapps.list".force = true;
    };
}
