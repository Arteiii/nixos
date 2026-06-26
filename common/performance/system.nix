{ lib, pkgs, ... }:

{
  # =========================================================================
  # HARDWARE & SYSTEM PERFORMANCE BASELINE
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  boot = {
    # use xanmod stable alternatively use zen or xanmod_latest
    # - https://wiki.nixos.org/wiki/Linux_kernel
    kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_stable;

    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    kernelParams = [
      # disables stuff like spectre mitigation (performance increase about 10% maybe a little more)
      # WARNING: cpu exploit protection turned OFF!
      "mitigations=off"

      # disables nmi
      "nowatchdog"

      # disables split lock detection
      # if system stutters (audio background apps) disable it if no stutters keep it on
      # - https://lwn.net/Articles/816298/
      # "split_lock_detect=off"

      # IOMMU passthrough
      "iommu=pt"

      # sets PCIe bus MPS to largest supported value
      # disable on random usb disconnects or network drops
      "pci=pcie_bus_perf"

      # bypass reliability checks for system clock
      # remove both lines if "time-warp" glitches occur
      "tsc=reliable"
      "clocksource=tsc"
    ];

    loader.timeout = 1;
  };

  security = {
    sudo.execWheelOnly = true;
    sudo.enable = lib.mkDefault true;
  };

  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-trusted-users
  nix.settings = {
    trusted-users = [
      "root"
      "@wheel"
    ];

    sandbox = true;
  };

}
