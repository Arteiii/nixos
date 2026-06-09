{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;

  wsl.interop.register = true; # allow pe type executables (windows programms with .exe for example)

  home-manager = {
    backupFileExtension = "backup";
    users = {
      "nixos" = import ../../users/wsl/home.nix;
    };
  };

  wsl = {
    defaultUser = "nixos";
    enable = true;
    wslConf.automount.root = "/mnt";
  };

  boot.isContainer = true;

  networking.hostName = "wsl-nixos";

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
  environment.variables.EDITOR = "vim";

  system.stateVersion = "25.11";
}
