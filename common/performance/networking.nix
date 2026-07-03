{ lib, ... }:

{
  # =========================================================================
  # NETWORK PERFORMANCE & LOW-LATENCY BASELINE
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  networking = {
    useNetworkd = lib.mkDefault true;
    networkmanager.enable = false;

    useDHCP = lib.mkDefault true;

    firewall = {
      enable = true;
      # allows icmp 'ping' requests
      allowPing = true;
    };

    wireless.iwd = {
      enable = true;
      settings.General = {
        AddressRandomization = "disabled";
      };
    };
  };

  boot.kernel.sysctl = {
    # bufferbloat mitigation: prevents background connections from delaying time sensitive ones
    # - https://github.com/torvalds/linux/blob/master/net/ipv4/tcp_bbr.c
    "net.core.default_qdisc" = "fq_codel";

    # improove bandwith and latency, especially on connections with minor data loss like wifi
    "net.ipv4.tcp_congestion_control" = "bbr";

    # keeping intermittent data bursts fast by disabling tcp slow start after idle
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # allow data exchange during initial tcp handshake reduces latency
    "net.ipv4.tcp_fastopen" = 3;

    # detect dropped connections faster, allowing immediate reconnect instead of hanging
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;

    # dynamically finds the optimal packet size for the route to avoid fragmentation delays
    "net.ipv4.tcp_mtu_probing" = 1;

    # allow the kernel more headroom for processing high-tickrate packets without dropping them
    "net.core.rmem_max" = 2500000;
    "net.core.wmem_max" = 2500000;
  };

  # manual: https://www.freedesktop.org/software/systemd/man/latest/resolved.conf.html
  services.resolved = {
    enable = true;

    settings = {
      Resolve = {
        # disables DNSSEC and LLMNR
        DNSSEC = "false";
        LLMNR = "false";

        DNSOverTLS = "yes";
        MulticastDNS = "no";
        Cache = "yes";
        DNS = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        FallbackDNS = [
          "8.8.8.8"
          "8.8.4.4"
        ];
        Domains = [
          "~."
        ];
      };
    };
  };
}
