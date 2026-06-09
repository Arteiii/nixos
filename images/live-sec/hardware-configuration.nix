{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/all-hardware.nix") ];

  boot.kernelParams = [ "mem_encrypt=on" ];

  swapDevices = [ ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "usb_storage"
  ];

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/SECURE_STORAGE";
    fsType = "ext4";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.device-timeout=5"
    ];
  };
}
