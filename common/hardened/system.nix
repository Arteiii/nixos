{ lib, ... }:

{
  # =========================================================================
  # HARDWARE & SYSTEM SECURITY BASELINE
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  boot = {
    # Hardened Linux kernel to mitigate runtime exploits
    # - Uses compile-time options like STACKPROTECTOR and FORTIFY_SOURCE
    # - wiki: https://wiki.nixos.org/wiki/Linux_kernel#Hardened_kernel
    # - Alternatives: '_zen' for better performance and responsivenes or '_latest' (both less secure)
    # kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;

    # IOMMU/DMA Attack Protection via Thunderbolt/USB-C
    # - General Docs & Known Issues: https://docs.kernel.org/arch/x86/iommu.html
    # - Parameters: https://docs.kernel.org/admin-guide/kernel-parameters.html
    kernelParams = [

      # Enables Intel VT-d hardware memory isolation
      # - In case of Graphic Issues try 'intel_iommu=igfx_off' to turn off the integrated graphics engine
      # - source: https://github.com/torvalds/linux/blob/master/drivers/iommu/intel/iommu.c
      "intel_iommu=on"

      # Bypasses translation for high-performance devices to fix GPU timeouts
      # - source: https://github.com/torvalds/linux/blob/master/drivers/iommu/iommu.c#L807
      "iommu=pt"
    ];

    loader.timeout = 1;
  };

  # Core System Security Configuration
  # - wiki: https://wiki.nixos.org/wiki/Security
  security = {
    # Restricts the kernel log (dmesg) access to root users only to prevent info leaks
    # - NOTE: breaks live system updates eg nixos-rebuild switch use nixos-rebuild boot instead
    # - source: https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/sysctl/kernel.rst#dmesg_restrict
    protectKernelImage = true;

    # Only users explicitly inside the 'wheel' group can execute commands via sudo
    # -wiki: https://wiki.nixos.org/wiki/Sudo
    sudo.execWheelOnly = true;
    sudo.enable = lib.mkDefault true;
  };

  # Nix Daemon Security Settings
  # ref: https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-trusted-users
  nix.settings = {
    # prevents unprivileged users from manipulating active store paths or forcing arbitrary builds
    trusted-users = [
      "root"
      "@wheel"
    ];

    # Prevents builds from leaking local system information or querying the live web
    # ref: https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-sandbox
    sandbox = true;
  };

}
