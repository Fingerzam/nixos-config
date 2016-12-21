# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Most of this is based on bodil's configs
  boot.cleanTmpDir = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  boot.kernel.sysctl."net.ipv4.tcp_challenge_ack_limit" = 999999999;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fi";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    # displayManager.slim.enable = true;
    # displayManager.sessionCommands = "${pkgs.networkmanagerapplet}/bin/nm-applet &";
    desktopManager.xterm.enable = false;
    layout = "fi";
    xkbOptions = "ctrl:nocaps,eurosign:e";
  };

  # Diable pc speaker
  boot.blacklistedKernelModules = [ "snd_pcsp" ];
  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  '';

  programs.ssh.startAgent = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
  # nixpkgs.config.virtualbox.enableExtensionPack = true;

  nix.trustedBinaryCaches = [ https://hydra.nixos.org ];

  services.udisks2.enable = true;
  services.gnome3.at-spi2-core.enable = true;

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovim vim emacs joe git nodejs ponysay mu powertop
    file inetutils lftp unzip xlibs.xev rsync fish

    # fonts
    source-code-pro

    # essentials
    tmux htop wget ponysay psmisc gptfdisk gnupg xclip xsel xdotool

    # build essentials
    binutils gcc gnumake pkgconfig python ruby

    # desktop components
    dmenu xlibs.xbacklight xscreensaver unclutter compton
    networkmanagerapplet volumeicon pavucontrol feh
    xlibs.xrandr liberation_ttf pavucontrol
    libnotify gnome3.gnome_themes_standard
    gnome3.adwaita-icon-theme gnome3.gsettings_desktop_schemas
    acpi dunst jq i3status i3lock i3blocks gnome3.dconf

    # desktop apps
    gnome3.gnome_terminal firefox chromium kde5.okular hipchat
    keepass slack which

    # console apps
    apg stow vagrant tree patchelf rustc cargo rustfmt rustracer

    # Clojure development
    leiningen boot

    # texlive
    (pkgs.texlive.combine {
      inherit (texlive)
        pgf
	beamer
	tools
	fancyvrb
	stmaryrd
	multirow
	collection-basic
	collection-binextra
        collection-latex
        # collection-latexextra
        collection-latexrecommended
        collection-mathextra;
    })

    # other
    dropbox openjdk
  ];

  fonts = {
     enableFontDir = true;
     enableGhostscriptFonts = true;
     fonts = with pkgs; [
       corefonts  # Micrsoft free fonts
       inconsolata  # monospaced
       ubuntu_font_family  # Ubuntu fonts
       unifont # some international languages
       source-code-pro #Adobe source code pro fonts
     ];
   };

  # Set default paper size
  environment.etc.papersize.text = "a4";

  # List services that you want to enable:

  # Enable automatic updates
  system.autoUpgrade.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware = {
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true; # This might be needed for Steam games
  };

  # Enable Postgresql
  services.postgresql.enable = false;
  services.postgresql.package = pkgs.postgresql94;
  services.postgresql.authentication = "local all all ident";


  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.kdm.enable = true;
  services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.fingerzam = {
    isNormalUser = true;
    name = "fingerzam";
    uid = 1000;
    extraGroups = [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" ];

  };

  users.extraGroups.vboxusers.members = [ "fingerzam" ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

  environment.variables.GTK_DATA_PREFIX = "${pkgs.gnome3.gnome_themes_standard}";

  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita
    gtk-icon-theme-name=gnome
    gtk-font-name=Droid Sans 20
    gtk-cursor-theme-name=Adwaita
    gtk-cursor-theme-size=0
    gtk-toolbar-style=GTK_TOOLBAR_BOTH
    gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images=1
    gtk-menu-images=1
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=1
    gtk-xft-antialias=1
    gtk-xft-hinting=1
    gtk-xft-hintstyle=hintslight
    gtk-xft-rgba=rgb
  '';

  environment.etc."fonts/local.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>

      <match target="font">
        <edit name="antialias" mode="assign">
          <bool>true</bool>
        </edit>
      </match>
      <match target="font">
        <edit name="hinting" mode="assign">
          <bool>true</bool>
        </edit>
      </match>
       <match target="font">
        <edit name="hintstyle" mode="assign">
          <const>hintslight</const>
        </edit>
      </match>
      <match target="font">
        <edit name="rgba" mode="assign">
          <const>rgb</const>
        </edit>
      </match>
      <match target="font">
        <edit mode="assign" name="lcdfilter">
          <const>lcddefault</const>
        </edit>
      </match>
      <match target="pattern">
        <test qual="any" name="family"><string>Helvetica</string></test>
        <edit name="family" mode="assign"><string>Droid Sans</string></edit>
      </match>

      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Droid Sans</family>
        </prefer>
      </alias>
      <alias>
        <family>serif</family>
        <prefer>
          <family>Droid Serif</family>
        </prefer>
      </alias>
      <alias>
        <family>monospace</family>
        <prefer>
          <family>PragmataPro</family>
        </prefer>
      </alias>

    </fontconfig>
  '';
}

