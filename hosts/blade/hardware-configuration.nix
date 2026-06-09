{
  lib,
  modulesPath,
  config,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  powerManagement = {
    enable = true;
  };

  services.power-profiles-daemon.enable = true;
  services.system76-scheduler.enable = true;
  services.tlp.enable = false;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.hardware.bolt.enable = true;
  hardware.graphics.enable = true;

  hardware.nvidia.open = false;

  services.xserver.videoDrivers = [
    "nvidia"
  ];

  systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement = {
      enable = true;
      finegrained = false;
    };

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = true;
      # ensure offload mode is disabled or removed to use nvidia
      offload.enable = false;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  boot = {
    initrd = {
      enable = true;
      systemd.enable = true;
      systemd.tpm2.enable = true;

      compressor = "zstd";
      compressorArgs = [ "-1" ];

      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "btrfs"
        "aesni_intel"
        "cryptd"
        "dm_crypt"
        "tpm_crb"
        "tpm_tis"
      ];

      luks.devices = {
        "enc-root" = {
          # use universal path instead of uuids
          device = "/dev/disk/by-partlabel/NIXROOT_ENC";
          allowDiscards = true;
          bypassWorkqueues = true;
          # tpm first on failure fallback to password enter
          crypttabExtraOpts = [
            "tpm2-device=auto"
            "tpm2-measure-pcr=yes"
          ];
        };
      };
    };

    kernelModules = [
      "kvm-intel"
      "i915"
      "vfat"
      "nls_cp437"
      "evdi"
    ];

    # performance tweaks
    kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.watermark_boost_factor" = 0;
      "vm.vfs_cache_pressure" = 50;

      "vm.transparent_hugepage_enabled" = "always";
      "vm.transparent_hugepage_defrag" = "always";

      # cleaner multitasking
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    };

    kernelParams = [
      "boot.shell_on_fail"
      "i915.fastboot=1"
      "i915.enable_psr=0"
      "8250.nr_uarts=0"
      "intel_iommu=on"
      "iommu=pt"
      "nvme_core.default_ps_max_latency_us=0"
      "nowatchdog"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/vg0-root";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd:1"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };
    "/home" = {
      device = "/dev/mapper/vg0-root";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd:1"
        "noatime"
        "discard=async"
        "space_cache=v2"
      ];
    };
    "/nix" = {
      device = "/dev/mapper/vg0-root";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "compress=zstd"
        "noatime"
      ];
    };
    "/var/log" = {
      device = "/dev/mapper/vg0-root";
      fsType = "btrfs";
      options = [
        "subvol=@var_log"
        "compress=zstd:1"
        "noatime"
        "commit=60"
      ];
    };
    "/var/lib/libvirt/images" = {
      device = "/dev/mapper/vg0-root";
      fsType = "btrfs";
      options = [
        "subvol=@kvm"
        "noatime"
        "autodefrag"
      ]; # CoW disabled via chattr +C
    };
    "/var/cache/ccache" = {
      device = "/dev/mapper/vg0-root";
      fsType = "btrfs";
      options = [
        "subvol=@ccache"
        "compress=zstd"
        "noatime"
        "commit=60"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };
  };

  # Swap via LVM
  swapDevices = [
    {
      device = "/dev/mapper/vg0-swap";
      priority = 0;
    }
  ];
  zramSwap = {
    enable = true;
    priority = 100;
  };

  services.fstrim.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
