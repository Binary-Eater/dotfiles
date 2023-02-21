self: super:
let
  lib32_gstreamer = (super.callPackage_i686 <nixpkgs/pkgs/development/libraries/gstreamer/core> {
    CoreServices = {};  # macOS dependency.....
  });
  lib32_gst-plugins-base = (super.callPackage_i686 <nixpkgs/pkgs/development/libraries/gstreamer/base> {
    Cocoa = {}; # macOS dependency.....
    OpenGL = (super.callPackage_i686 <nixpkgs/nixos/modules/hardware/opengl.nix> {});
    gstreamer = lib32_gstreamer;
  });
  lib32_gst-libav = (super.callPackage_i686 <nixpkgs/pkgs/development/libraries/gstreamer/libav> {
    gst-plugins-base = lib32_gst-plugins-base;
    gstreamer = lib32_gstreamer;
    # TODO fix NixOS upstream derivation because libAV (ffmpeg fork) is deprecated
    libav = (super.callPackage_i686 <nixpkgs/pkgs/development/libraries/ffmpeg/5.nix> {
      Cocoa = {};        # macOS dependency.....
      CoreMedia = {};    # macOS dependency.....
      VideoToolbox = {}; # macOS dependency.....
    });
  });
  lib32_gst-plugins-ugly = (super.callPackage_i686 <nixpkgs/pkgs/development/libraries/gstreamer/ugly> {
    CoreFoundation = {};  # macOS dependency.....
    DiskArbitration = {}; # macOS dependency.....
    IOKit = {};           # macOS dependency.....
    gst-plugins-base = lib32_gst-plugins-base;
  });
  lib32_gst-plugins-good = (super.callPackage_i686 <nixpkgs/pkgs/development/libraries/gstreamer/good> {
    Cocoa = {}; # macOS dependency.....
    gst-plugins-base = lib32_gst-plugins-base;
  });
in
{
  binary-eater = with super.pkgs; buildEnv {
    name = "binary-eater";
    paths = [
      discord                       # Discord Content Sharing Application
      feh                           # Image Viewer/Cataloguer
      fractal                       # Matrix Client
      git                           # VCS
      graphviz                      # GraphViz for erc-social-graph
      imagemagick                   # Image Manipulation Library
      isync                         # IMAP Maildir Sync Client
      kicad                         # PCB Design Software
      mu                            # Maildir Indexing Program
      neofetch                      # Terminal Startup Display
      pass                          # GPG-based Password Manager
      protonmail-bridge             # ProtonMail Bridge
      qutebrowser                   # Web Browser
      saleae-logic                  # Saleae Logic Analyzer
      slack                         # Slack Chat Application
      starship                      # Shell-agnostic Prompt Manager
      texlive.combined.scheme-full  # Minimal TeX setup
      w3m                           # Text-based Web Browser
      xdg-user-dirs                 # User Directories Generator
      xdg_utils                     # XDG Utilities
      xdotool                       # X11 Automation Tool
      xfontsel                      # XLDF Font Selection Renderer
      xlsfonts                      # XLDF Font Selection Lister
      xorg.xmodmap                  # X11 Keymap Manipulator
      xscreensaver                  # XScreenSaver
      (wineWowPackages.staging.overrideDerivation (previousAttrs: {
        buildInputs = previousAttrs.buildInputs ++ [
          lib32_gstreamer
          lib32_gst-plugins-base
          lib32_gst-libav
          lib32_gst-plugins-ugly
          lib32_gst-plugins-good
        ];
        postInstall = previousAttrs.postInstall + ''
          # Wrapping Wine is tricky.
          # https://github.com/NixOS/nixpkgs/issues/63170
          # https://github.com/NixOS/nixpkgs/issues/28486
          # The main problem is that wine-preloader opens and loads the wine(64) binary, and
          # breakage occurs if it finds a shell script instead of the real binary. We solve this
          # by setting WINELOADER to point to the original binary. Additionally, the locations
          # of the 32-bit and 64-bit binaries must differ only by the presence of "64" at the
          # end, due to the logic Wine uses to find the other binary (see get_alternate_loader
          # in dlls/kernel32/process.c). Therefore we do not use wrapProgram which would move
          # the binaries to ".wine-wrapped" and ".wine64-wrapped", but use makeWrapper directly,
          # and move the binaries to ".wine" and ".wine64".
          for i in wine wine64 ; do
            prog="$out/bin/$i"
            if [ -e "$prog" ]; then
              hidden="$(dirname "$prog")/.$(basename "$prog")"
              mv "$prog" "$hidden"
              makeWrapper "$hidden" "$prog" \
                --argv0 "" \
                --set WINELOADER "$hidden" \
                --prefix GST_PLUGIN_SYSTEM_PATH_1_0 ":" "$GST_PLUGIN_SYSTEM_PATH_1_0"
            fi
          done
        '';
      }))                            # Wine (32/64-bit)
      winetricks                    # Wine sandboxing
      yubikey-manager               # YubiKey Manager
    ];
  };
}
