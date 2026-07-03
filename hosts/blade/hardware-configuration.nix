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
  services.thermald.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.hardware.bolt.enable = true;
  hardware.graphics.enable = true;

  hardware.nvidia.open = false;
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = false;

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

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

      services.lvm.enable = true;

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
        "dm_mod"
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

    extraModprobeConfig = ''
      options ec_sys write_support=1
      options nct6687 force=1
    '';

    # extraModulePackages = [ config.boot.kernelPackages.razer-laptop-ec ];

    kernelModules = [
      "razer_laptop_ec"
      "coretemp"
      "nct6687"
      "kvm-intel"
      "i915"
      "vfat"
      "nls_cp437"
      "evdi"
      "apparmor"
    ];

    # performance tweaks
    kernel.sysctl = {
      "vm.swappiness" = 60;
      "vm.watermark_boost_factor" = 0;
      "vm.vfs_cache_pressure" = 50;

      "vm.transparent_hugepage_enabled" = "always";
      "vm.transparent_hugepage_defrag" = "always";

      # cleaner multitasking
      "kernel.sched_cfs_bandwidth_slice_us" = 5000;
    };

    kernelParams = [
      "boot.shell_on_fail"
      "snd_hda_intel.power_save=0"
      "snd_hda_intel.power_save_controller=N"
      "ahci.mobile_lpm_policy=3"
      "i915.enable_psr=0"
      "8250.nr_uarts=0"
      "intel_iommu=on"
      "iommu=pt"
      "nvme_core.default_ps_max_latency_us=0"
      "nowatchdog"
      "apparmor=1"
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
        "x-systemd.device-timeout=infinity"
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
        "bind"
        "nofail"
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
      options = [
        "x-systemd.device-timeout=infinity"
      ];
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
