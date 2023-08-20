# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

with lib;

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Specify kernel package used.
  # boot.kernelPackages = pkgs.linuxPackages; # Default value
  boot.kernelPackages = pkgs.linuxPackages_6_1; # Latest kernel

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
    splashImage = null;
  };
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/04df6014-3343-4a3b-8721-b4e844b9c714";
      preLVM = true;
      keyFile = "/etc/BINARY-EATER-DEV/luks_decrypt_key";
    };
  };
  boot.initrd.secrets = {
    "/etc/BINARY-EATER-DEV/luks_decrypt_key" = /boot/decryption-keyfiles/LinuxVolGroupKeyfile.bin;
  };

  networking.hostName = "BINARY-EATER-DEV"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp42s0.useDHCP = true; # 2.5Gbps interface
  networking.interfaces.enp6s0.useDHCP = true;  # 1Gbps interface

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # Explicitly setting values in-case defaults change.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "";

  # Configure display manager
  services.xserver.displayManager.startx.enable = true;
  services.xserver.displayManager.defaultSession = "none+xmonad";

  # Configure desktop/window manager
  services.xserver = {
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.extra
      ];
    };
  };

  # KDE test environment
  services.xserver.desktopManager.plasma5.enable = false;

  # Configure X server screen settings
  services.xserver.screenSection = ''
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
  '';

  # Configure sudoers file
  security.sudo.extraConfig = concatStringsSep "\n" [
    "Defaults timestamp_timeout=0"
    "Defaults passwd_tries=1"
  ];

  # Configure video drivers
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ]; # Need modesetting when using non-default kernel package with nixOS

  # Enable OpenGL.
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable (grudgingly) GNOME keyring for use with fractal
  services.gnome.gnome-keyring.enable = true;

  # Enable (grudgingly) GNOME virtual file system for use with fractal
  services.gvfs.enable = true;
  services.gvfs.package = (pkgs.gvfs.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [
      pkgs.glib-networking
      pkgs.libsoup
    ];
  }));

  # systemd.logind configuration.
  services.logind.extraConfig = concatStringsSep "\n" [
    "HandlePowerKey=suspend"           # Suspend system when power key is pressed
    "HandlePowerKeyLongPress=poweroff" # Power down system when power key is long pressed
  ];

  /* NOTE: Disabling standard approach to sound in NixOS
   *
   * # Enable sound.
   * sound.enable = true;
   * hardware.pulseaudio.enable = true;
   *
   * # Do not set HDA Nvidia as default card
   * sound.extraConfig = concatStringsSep "\n" [
   *   "defaults.pcm.card 1"
   *   "defaults.ctl.card 1"
   * ];
   */

  # Enable pipewire for sound.
  security.rtkit.enable = true; # rtkit is optional but recommended
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.binary-eater = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "input" ]; # UNIX groups.
    #packages = [ pkgs.steam ]; # User-restricted packages
  };

  # Bind mount NixOS configurations to user directory on different fs.
  # This enables the system configuration to be tracked in the same
  # git repository with the user home directory as the work tree.
  fileSystems."/home/binary-eater/.config/nixos-system/nixos" = {
    device = "/etc/nixos/";
    options = [ "bind" ];
  };

  # Allow unfree software like NVIDIA proprietary drivers.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"
    "steam"
    "steam-original"
    "steam-run"
  ];

  # Enable steam program.
  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Core tools
    dunst                # Notification Daemon
    vim                  # Core Editor
    volumeicon           # ALSA Volume Control System Tray Utility
    networkmanagerapplet # NetworkManager System Tray Utility

    # User tools
    alsaUtils              # ALSA Utilities
    emacs                  # Editor
    rxvt-unicode           # Terminal Emulator
    xsel                   # Command-line X Selection Tool
    trayer                 # System Tray
    haskellPackages.xmobar # XMobar Status Bar
  ];

  # Set vim as the default editor using the EDITOR variable.
  programs.vim.defaultEditor = true;

  # List fonts installed in system profile.
  fonts.fonts = with pkgs; [
    source-code-pro # Source Code Pro
    mononoki        # Mononoki Nerd Font
    font-awesome    # Font Awesome Free
  ];

  # List services that you want to enable:
  services.xserver.enable = true;

  # Enable GnuPG agent.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    #pinentryFlavor = "curses";
  };

  # Enable smart card support.
  services.pcscd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = false;
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = false;
    };
  };

  # Add udev rules.
  services.udev.extraRules = concatStringsSep "\n" [
    # Initialize Apple USB SuperDrive
    # TODO debug
    "ACTION==\"add\", ATTRS{idProduct}==\"1500\", ATTRS{idVendor}==\"05ac\", DRIVERS==\"usb\", RUN+=\"${pkgs.sg3_utils}/bin/sg_raw %r/sr%n EA 00 00 00 00 00 01\""
  ];

  # Enable virtual box.
  virtualisation.virtualbox.host.enable = false;
  # users.extraGroups.vboxusers.members = [ "binary-eater" ];

  # Enable docker rootless runtime.
  virtualisation.docker.rootless.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

