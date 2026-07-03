{ pkgs, ... }:
{
  imports = [
    ../../common/upgrade.nix
    ../../common/cleanup.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "blade-deploy-key:Zp0tsAbtLqEL/n7TPkQKZ815D7RMvucKYQpPgPWr70A="
  ];

  hardware.enableRedistributableFirmware = true;

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [
    "root"
    "dev-user"
    "arteii"
  ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  environment.systemPackages = with pkgs; [
    parted
  ];

  environment.shellAliases = {
    unlock-media = "sudo cryptsetup luksOpen /dev/sda1 media-crypt && sudo mount /mnt/media";
    lock-media = "sudo umount /mnt/media && sudo cryptsetup luksClose media-crypt";
  };

  systemd.services.samba-smbd.after = [ "mnt-media.mount" ];
  systemd.services.samba-smbd.wants = [ "mnt-media.mount" ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS-Media";
        "netbios name" = "argonone";
        "security" = "user";
        "map to guest" = "Bad User";

        "use sendfile" = "yes";
        "strict locking" = "no";
        "getwd cache" = "yes";
        "min receivefile size" = "16384";
        "aio read size" = "1";
        "aio write size" = "1";
      };
      media = {
        "path" = "/mnt/media";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "write list" = "media-manager";
        "force user" = "media-manager";
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };

    extraConfig = ''
      Match User media-manager
        ChrootDirectory /mnt/media
        ForceCommand internal-sftp
        PasswordAuthentication no
        PubkeyAuthentication yes
    '';
  };

  networking = {
    hostName = "argonone";
    firewall.allowedTCPPorts = [ 22 ];
    useDHCP = true;
  };

  services.journald.extraConfig = ''
    Storage=persistent
    Compress=yes
  '';

  boot = {
    initrd.allowMissingModules = true;

    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;

    kernelParams = [
      "console=tty1"
      "console=ttyAMA0,115200"
    ];

    supportedFilesystems = [
      "vfat"
      "exfat"
      "ntfs"
      "btrfs"
      "ext4"
    ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "uas"
      "pcie_brcmstb"
    ];

    # comp mode for sd card
    loader.generic-extlinux-compatible.enable = true;
  };

  users.mutableUsers = false;

  users.users = {
    dev-user = {
      isNormalUser = true;
      description = "Dev Environment";
      extraGroups = [
        "wheel"
        "networkmanager"
        "media-manager"
      ];
      packages = with pkgs; [
        vim-full
        git
        ripgrep
        gnumake
        gcc
        clang
        nodejs
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBL0LgBXkHnsB28rBLjL+SMErUS/BaX1mRZzDIVcvl6I blade"
      ];
    };

    media-manager = {
      isSystemUser = true;
      description = "Storage Manager";
      group = [
        "media-manager"
        "wheel"
        "networkmanager"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBL0LgBXkHnsB28rBLjL+SMErUS/BaX1mRZzDIVcvl6I blade"
      ];
    };
  };

  users.groups.media-manager = { };

  environment.variables.EDITOR = "vim";
  system.stateVersion = "26.05";
}
