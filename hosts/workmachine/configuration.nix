# Edit this conguration file to define what should be installed on
# your system.  Help is available in the conguration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networking.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];  

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Congure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Congure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redene it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Dene a user account. Don't forget to set a password with ‘passwd’.
  users.users.arteii = {
    isNormalUser = true;
    description = "Ben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  managed by home manager /etc/nixos/users/arteii/home.nix
    ];
  };

  home-manager = {
    backupFileExtension = "backup";
    users = {
      "arteii" = import ../../users/arteii/home.nix;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # set prole pciture for arteii
  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp /etc/nixos/users/arteii/profilepicture.png /var/lib/AccountsService/icons/arteii
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/arteii\n" > /var/lib/AccountsService/users/arteii

    chown root:root /var/lib/AccountsService/users/arteii
    chmod 0600 /var/lib/AccountsService/users/arteii

    chown root:root /var/lib/AccountsService/icons/arteii
    chmod 0444 /var/lib/AccountsService/icons/arteii
  '';


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system prole. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like le locations and database versions
  # on your system were taken. It‘s perfectly ne and recommended to leave
  # this value at the release version of the rst install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man conguration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
