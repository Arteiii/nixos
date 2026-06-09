{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_hardened;
  boot.initrd.systemd.enable = true;

  nix.settings.substituters = lib.mkForce [ ];

  systemd.services.randomize-identity = {
    wantedBy = [ "sysinit.target" ];
    before = [
      "systemd-hostnamed.service"
      "systemd-timesyncd.service"
    ];
    path = [
      pkgs.coreutils
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Hostname Randomisierung
      NEW_NAME=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
      hostnamectl set-hostname $NEW_NAME

      # Zeitzonen Randomisierung
      ZONES=("UTC" "Etc/GMT+1" "Etc/GMT-1" "Pacific/Honolulu" "Asia/Tokyo" "Europe/London")
      RANDOM_ZONE=''${ZONES[$RANDOM % ''${#ZONES[@]}]}
      timedatectl set-timezone $RANDOM_ZONE
    '';
  };

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "mode=755"
    ];
  };

  environment.shellAliases = {
    "unlock-storage" =
      "sudo cryptsetup luksOpen /dev/disk/by-label/SECURE_STORAGE vault && sudo mount /dev/mapper/vault /persist";
    "lock-storage" = "sudo umount /persist && sudo cryptsetup luksClose vault";
  };

  system.activationScripts.removeMetadata = ''
    rm -rf /etc/machine-id
    touch /etc/machine-id
  '';

  environment.systemPackages = with pkgs; [
    wireguard-tools
    iptables
    fzf
  ];
}
