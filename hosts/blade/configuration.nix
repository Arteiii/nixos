{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

{
  imports = [
    ../../common/hardened/default.nix
    ./hardware-configuration.nix
    ./networking.nix
    # ./firejail.nix
    ./proton-vpn.nix
    ./nbfc.nix
  ];

  system.nixos.tags = [ "Linux-${config.boot.kernelPackages.kernel.version}" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    download-buffer-size = 536870912; # 512mb
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "security" = "user";
      };
      "Videos" = {
        "path" = "/home/arteii/Videos";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
    };
  };

  programs.dconf.enable = true;

  programs.dconf.profiles.gdm.databases = [
    {
      settings = {
        "org/gnome/login-screen" = {
          logo = "${../../assets/sparx.png}";
        };
        "org/gnome/desktop/session" = {
          idle-delay = lib.gvariant.mkUint32 0;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          idle-dim = false;
        };
      };
    }
  ];

  systemd.user.services = {
    gnome-rfkill-baseline = {
      enable = true;
      description = "Lock wireless radios down on user login";
      wantedBy = [ "graphical-session.target" ];
      script = ''
        ${pkgs.util-linux}/bin/rfkill block wifi
      '';
    };
    evolution-calendar-factory.enable = false;
    evolution-addressbook-factory.enable = false;
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=100M
      SystemMaxFiles=5
      ReadKMsg=no
      Storage=volatile
    '';

    # prevents idle checks at login
    displayManager.gdm.autoSuspend = false;

    gnome.core-developer-tools.enable = true;
    gnome.games.enable = false;

    gnome.gnome-keyring.enable = true;

    fail2ban.enable = true;
  };

  security = {
    pam = {
      services.login.enableGnomeKeyring = true;
      services.gdm.enableGnomeKeyring = true;
      # u2f.enable = true; # enable for yubikey support
      loginLimits = [
        {
          domain = "*";
          type = "hard";
          item = "nproc";
          value = "8192";
        }
      ];
    };

    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };

    sudo.extraRules = [
      {
        users = [ "arteii" ];
        commands = [
          {
            command = "${pkgs.iproute2}/bin/ip netns exec protonvpn *";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    epiphany
    totem
    geary
    evince
    seahorse
  ];

  environment.sessionVariables = {
    GS_ENABLE_GPU_ACCEL = "1";
    GDK_DEBUG = "no-debug";
  };

  systemd = {
    targets.hibernate.enable = true;
    targets.hybrid-sleep.enable = true;

    services = {
      systemd-udev-settle.enable = false;
      nm-privload-status.enable = false;

      NetworkManager-wait-online.enable = false;

      # dont auto start bluetooth wait for user action to trigger start
      bluetooth.wantedBy = lib.mkForce [ ];
    };

  };

  # enables physical USB port protection on lockscreens
  services.usbguard = {
    enable = true;
    dbus.enable = true;
    implicitPolicyTarget = "allow";
  };

  services.printing.startWhenNeeded = true;

  # fix gnome error: stop looking for network manager
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.usbguard") === 0 && subject.active === true) {
        return polkit.Result.YES;
      }
    });
  '';

  boot = {
    supportedFilesystems = [
      "vfat"
      "btrfs"
    ];

    binfmt.emulatedSystems = [ "aarch64-linux" ];

    plymouth.enable = false;

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = false;
        configurationLimit = 8;
        copyKernels = true;
      };

      systemd-boot = {
        enable = false;
        configurationLimit = 4; # keep boot menu clean
        editor = false; # disable editing kernel params at boot
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
      qemu.runAsRoot = false;
    };
  };

  # systemd.services.systemd-binfmt.serviceConfig.Type = lib.mkForce "simple";

  # silence x11 errors
  systemd.tmpfiles.settings."10-silence-x11" = {
    "/tmp/.X11-unix" = {
      d = {
        mode = "1777";
        user = "root";
        group = "root";
        age = "-";
      };
    };
  };

  fileSystems."/etc/nixos" = {
    device = "/home/arteii/nixos-config";
    options = [ "bind" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
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
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.displayManager.gdm.wayland = true;
  programs.xwayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Congure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    extraConfig = {
      pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.groups.ccache = { };
  users.groups.netdev = { };

  # Dene a user account. Don't forget to set a password with ‘passwd’.
  users.users.arteii = {
    isNormalUser = true;
    description = "Ben";
    extraGroups = [
      "netdev"
      "wheel"
      "systemd-journal"
      "libvirtd"
      "kvm"
      "ccache"
      "firejail"
    ];
  };

  environment.sessionVariables = {
    CCACHE_DIR = "/var/cache/ccache";
  };

  systemd.user.services.boot-diagnostic-log = {
    description = "Generate fresh boot performance and error log";
    wantedBy = [ "default.target" ];
    script = ''
      DESKTOP_DIR="$HOME/Desktop"
      LOG_FILE="$DESKTOP_DIR/boot_latest.log"

      mkdir -p "$DESKTOP_DIR"

      echo "=== NIXOS LATEST BOOT DIAGNOSTIC CODES ===" > "$LOG_FILE"
      echo "Generated on: $(date)" >> "$LOG_FILE"
      echo "Active User:  $USER" >> "$LOG_FILE"
      echo "Host Machine: $(hostname)" >> "$LOG_FILE"
      echo "" >> "$LOG_FILE"

      echo "--- 1. OVERALL TIMINGS ---" >> "$LOG_FILE"
      ${pkgs.systemd}/bin/systemd-analyze >> "$LOG_FILE" 2>&1
      echo "" >> "$LOG_FILE"

      echo "--- 2. CRITICAL CHAIN (The Real Sequential Bottlenecks) ---" >> "$LOG_FILE"
      ${pkgs.systemd}/bin/systemd-analyze critical-chain graphical.target >> "$LOG_FILE" 2>&1
      echo "" >> "$LOG_FILE"

      echo "--- 3. ACTIVELY FAILED SERVICES ---" >> "$LOG_FILE"
      echo "System Services:" >> "$LOG_FILE"
      ${pkgs.systemd}/bin/systemctl --failed --no-legend >> "$LOG_FILE" 2>&1 || true
      echo "User Services:" >> "$LOG_FILE"
      ${pkgs.systemd}/bin/systemctl --user --failed --no-legend >> "$LOG_FILE" 2>&1 || true
      echo "" >> "$LOG_FILE"

      echo "--- 4. ACTIONABLE USERSPACE ERRORS ---" >> "$LOG_FILE"
      ${pkgs.systemd}/bin/journalctl -b 0 -p 3 --no-pager | ${pkgs.gnugrep}/bin/grep -v -E "ACPI|BIOS|wmi_bus|Stale Data|dw-apb-uart" >> "$LOG_FILE" 2>&1 || true    

      # Guarantees the script itself finishes with a clean success code
      exit 0
    '';
  };

  home-manager = {
    backupFileExtension = "backup";
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];

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
  systemd.tmpfiles.rules = [
    "d /var/cache/ccache 2770 root ccache -"
    "d /var/lib/AccountsService/users 0755 root root -"
    "d /var/lib/AccountsService/icons 0755 root root -"
    "C+ /var/lib/AccountsService/icons/arteii 0444 root root - /etc/nixos/users/arteii/profilepicture.png"
    "f+ /var/lib/AccountsService/users/arteii 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/arteii\\n"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system prole. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim-full
    git
    e2fsprogs
    virt-manager
    virt-viewer
    qemu_kvm
    nvtopPackages.full
    displaylink
    coreutils
    btop
    lm_sensors

    apparmor-parser
    apparmor-profiles
    apparmor-utils

    gnomeExtensions.vitals
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like le locations and database versions
  # on your system were taken. It‘s perfectly ne and recommended to leave
  # this value at the release version of the rst install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man conguration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
