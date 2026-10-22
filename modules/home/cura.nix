# Cura was removed from nixpkgs as unmaintained (2026-05-22:
# `pkgs.cura` now throws), so it's built here straight from UltiMaker's own
# AppImage release instead. appimageTools.wrapType2 unpacks that AppImage
# into an ordinary derivation ($out/bin/cura) — reproducible, garbage
# collectable, no manual download/chmod +x dance outside the Nix store.
#
# The desktop entry below (built fresh with makeDesktopItem rather than
# patched from the AppImage's own — its Exec=/Icon= point at the raw
# AppImage layout, not this wrapped derivation's) is what lets Nautilus and
# browser downloads open .stl/.3mf/.gcode directly in Cura instead of
# falling back to "no application". model/stl, model/3mf, text/x.gcode and
# text/x-gcode-gx are all already registered by shared-mime-info, so unlike
# drawio (see file-manager.nix) no custom mimetype XML glob is needed —
# only the default-handler wiring, also in file-manager.nix.
{
  flake.homeModules.cura-user =
    { pkgs, lib, ... }:
    let
      pname = "cura";
      version = "5.13.0";

      src = pkgs.fetchurl {
        url = "https://github.com/Ultimaker/Cura/releases/download/${version}/UltiMaker-Cura-${version}-linux-X64.AppImage";
        sha256 = "100f068127b2598167f00ba4db0e0699ded45adf97bbab2d22ff171a1e1ecc40";
      };

      # Only used to pull the icon out of the AppImage's squashfs.
      appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };

      desktopItem = pkgs.makeDesktopItem {
        name = pname;
        exec = pname;
        icon = pname;
        desktopName = "UltiMaker Cura";
        comment = "3D printer slicing application";
        categories = [
          "Graphics"
          "Engineering"
        ];
        mimeTypes = [
          "model/stl"
          "model/3mf"
          "text/x.gcode"
          "text/x-gcode-gx"
        ];
      };
    in
    {
      home.packages = [
        (pkgs.appimageTools.wrapType2 {
          inherit pname version src;

          extraInstallCommands = ''
            install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
            install -m 444 -D ${appimageContents}/cura-icon.svg $out/share/icons/hicolor/scalable/apps/${pname}.svg
          '';

          meta = {
            description = "3D printer slicing application";
            homepage = "https://ultimaker.com/software/ultimaker-cura/";
            license = lib.licenses.lgpl3Plus;
            platforms = [ "x86_64-linux" ];
            mainProgram = "cura";
          };
        })
      ];
    };
}
