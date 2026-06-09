{ pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "arteii";
  home.homeDirectory = "/home/arteii";

  nixpkgs.config.allowUnfree = true;

  imports = [
    ./firefox.nix
    ./git.nix
    ./zsh.nix
    ./nvim.nix
    ./email.nix
    ./ssh.nix
    ./librewolf.nix
    ./proton-pass.nix
    ../common/vscode.nix
    ../common/rustrover.nix
    ../common/clion.nix
  ];

  dconf.settings = {
    # Dark Mode Gnome
    "org/gnome/desktop/background" = {
      picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/privacy" = {
      disable-wifi = true;
    };

    # Make the user interface feel absolutely instant
    "org/gnome/desktop/interface" = {
      enable-animations = true;
    };

    # Stop the Activities Overview from lagging when you tap the Super key
    # Disables external background indexing engines during standard shell search
    "org/gnome/desktop/search-providers" = {
      disable-external = true;
      disabled = [
        "org.gnome.Contacts.desktop"
        "org.gnome.Characters.desktop"
        "org.gnome.Calendar.desktop"
      ];
    };

    "org/gnome/settings-daemon/plugins/smartcard" = {
      active = false;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      active = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
    };

    "org/gnome/desktop/session" = {
      idle-delay = 1200;
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
      clock-enabled = true;
      show-notifications = false;
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>s";
      command = "systemctl suspend";
      name = "Suspend System";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
  };

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    spotify
    caligula

    # notes:
    obsidian

    # misc:
    alacritty
    tre-command # like tree but follows gitignore
    tree

    # usb helper cli utils
    usbutils

    # security:
    gnupg

    # nixos
    sops
    age
    nixfmt-tree

    # dev:
    ccache

    ffmpeg
    bear

    direnv

    wl-clipboard
    xclip

    killall
    parted
    veracrypt

    bandwhich
    nethogs
    tcpdump
    tshark
    mitmproxy
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      keyboard.bindings = [
        {
          key = "M";
          mods = "Alt";
          action = "ToggleMaximized";
        }
      ];
      window = {
        # remove the top title bar
        decorations = "None";
        padding = {
          x = 5;
          y = 5;
        };
      };
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
      };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 11.0;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
