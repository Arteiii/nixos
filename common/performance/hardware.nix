{
  config,
  pkgs,
  lib,
  ...
}:

{
  # =========================================================================
  # HARDWARE ACCELERATION & GENERAL PERFORMANCE BASELINE
  # =========================================================================

  # dynamically scales cpu frequency based on load
  # - https://wiki.nixos.org/wiki/Power_Management

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # https://wiki.nixos.org/wiki/Graphics

    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        intel-media-driver # broadwell and newer
        intel-vaapi-driver # old intel gpus
        libvdpau-va-gl # translation layer for VDPAU
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
      ];
    };
  };

  # https://wiki.nixos.org/wiki/Zram
  zramSwap = {
    enable = true;

    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  services = {
    fstrim.enable = true;

    power-profiles-daemon.enable = true;
    tlp.enable = false;
  };

  boot = {
    # fastboot intel graphics drivers
    kernelParams = [ "i915.fastboot=1" ];
  };
}
