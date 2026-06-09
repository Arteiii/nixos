{ lib, ... }:

{
  # Tells NixOS to use modern systemd-networkd and bypass the old legacy scripts.
  networking.useNetworkd = true;
  networking.networkmanager.enable = false;
  networking.useDHCP = true;

  # disable iwd automatic boot execution (on-demand only)
  systemd.services.iwd.wantedBy = lib.mkForce [ ];
  # systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  # systemd.network.wait-online.enable = false;

  networking = {
    hostName = "blade";
    firewall.allowedUDPPorts = [ 5353 ]; # for local Avahi discovery

    wireless.iwd = {
      enable = true;
      settings.General = {
        AddressRandomization = "network";
      };
    };
  };

  systemd.network.netdevs = {
    "30-vlan-home" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan-home";
      };
      vlanConfig.Id = 10;
    };
  };

  systemd.network.networks = {
    "40-enp0s20f0u4u3" = {
      matchConfig.Name = "enp0s20f0u4u3";
      # linkConfig.RequiredForOnline = "no";
      networkConfig = {
        DHCP = "yes";
        IPv6PrivacyExtensions = "kernel";
        IPv4Forwarding = false;
        IPv6Forwarding = false;
      };
      vlan = [ "vlan-home" ];
    };

    "40-vlan-home" = {
      matchConfig.Name = "vlan-home";
      linkConfig.RequiredForOnline = "no";
      address = [ "192.168.10.50/24" ];
      networkConfig = {
        DHCP = "no";
        IPv6PrivacyExtensions = "kernel";
        IPv4Forwarding = false;
        IPv6Forwarding = false;
      };
    };
  };

  systemd.services.chronyd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];

    serviceConfig = {
      Type = lib.mkForce "simple";
    };
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      [Resolve]
      DNSOverTLS=yes
      MulticastDNS=no
      DNS=9.9.9.9 149.112.112.112
      FallbackDNS=1.1.1.1 1.0.0.1
      Domains=fritz.box ~.
    '';
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = false;
      addresses = false;
      workstation = false;
    };
  };

  boot.kernel.sysctl = {
    # increase max network interface buffer sizes
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;

    # TCP buffer autotuning (Min, Default, Max in Bytes)
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";

    # increase max number of packets allowed in queue
    "net.core.netdev_max_backlog" = "5000";

    # enable tcp fast open (TFO)
    "net.ipv4.tcp_fastopen" = 1;
  };
}
