self: super:
{
  binary-eater = with super.pkgs; buildEnv {
    name = "binary-eater";
    paths = [
      discord                       # Discord Content Sharing Application
      feh                           # Image Viewer/Cataloguer
      git                           # VCS
      imagemagick                   # Image Manipulation Library
      kicad                         # PCB Design Software
      neofetch                      # Terminal Startup Display
      pass                          # GPG-based Password Manager
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
      yubikey-manager               # YubiKey Manager
    ];
  };
}
