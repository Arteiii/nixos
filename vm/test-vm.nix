{ ... }:

{
  imports = [
    ../common/performance/default.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };

  boot = {
    supportedFilesystems = [
      "vfat"
      "btrfs"
    ];

    # binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
      qemu.options = [ "-vga virtio" ];
    };
  };

  users.users.testuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "test";
  };

  system.stateVersion = "26.05";
}
