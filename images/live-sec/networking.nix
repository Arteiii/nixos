{
  pkgs,
  ...
}:

{
  imports = [
    ../../common/hardened/networking.nix
    ./modules/wireguard.nix
  ];

  networking = {
    networkmanager.enable = false;
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="module", KERNEL=="bluetooth", RUN+="${pkgs.kmod}/bin/modprobe -r bluetooth"
    # disable wifi module
    # ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iproute2}/bin/ip link set dev %k down"
  '';

  services.chrony.enable = true;
  services.resolved = {
    enable = true;
    dnsovertls = "true";
  };
}
