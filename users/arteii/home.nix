{ pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "arteii";
  home.homeDirectory = "/home/arteii";

  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ./firefox.nix
    ./git.nix
    ./zsh.nix
    ./nvim.nix
    ./email.nix
    ./ssh.nix
    ./gnome.nix
    ./gpg/gpg.nix

    # ./librewolf.nix # out of support for nix
    # ./proton-pass.nix
    ../common/vscode.nix
  ];

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    spotify
    caligula

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

    bandwhich
    nethogs
    tcpdump
    tshark
    mitmproxy

    gnomeExtensions.vitals

    google-chrome

    _7zz
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
