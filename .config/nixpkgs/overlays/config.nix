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
      clang-tools                   # Clang tools
      discord                       # Discord Content Sharing Application
      feh                           # Image Viewer/Cataloguer
      fractal                       # Matrix Client
      gdb                           # GNU Debugger
      git                           # VCS
      graphviz                      # GraphViz for erc-social-graph
      helvum                        # PipeWire Patchbay
      imagemagick                   # Image Manipulation Library
      isync                         # IMAP Maildir Sync Client
      kicad                         # PCB Design Software
      languagetool                  # Proof-reading Program
      mu                            # Maildir Indexing Program
      neofetch                      # Terminal Startup Display
      pass                          # GPG-based Password Manager
      protonmail-bridge             # ProtonMail Bridge
      ripgrep                       # grep Alternative
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
      wineWowPackages.staging       # Wine (32/64-bit)
      winetricks                    # Wine sandboxing
      yubikey-manager               # YubiKey Manager

      (retroarch.override {
        cores = with libretro; [
          desmume
        ];
      })
    ];
  };
}
