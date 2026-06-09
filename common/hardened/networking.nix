{ lib, ... }:

{
  # =========================================================================
  # NETWORK SECURITY & HARDENING BASELINE
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  networking = {
    # Uses systemd-networkd as the backend
    # - More stable for VLANs, bridges, and complex static setups
    # - Alternatives: Turn networkmanager on if you need graphical tray applets :(
    # - wiki: https://wiki.nixos.org/wiki/Systemd-networkd
    useNetworkd = lib.mkDefault true;
    networkmanager.enable = false;

    # Disables automatic IP assignment for all interfaces globally
    # - Prevents every virtual or physical port from shouting for an IP, which is cleaner and more secure
    # - Alternatives: Turn on if you want a "plug and play" experience where every cable works instantly
    useDHCP = lib.mkDefault false;

    # Generates random, temporary IPv6 addresses for outgoing traffic
    tempAddresses = "default";

    # Directs time synchronization to privacy-respecting servers
    # - Prevents leakage of your local IP and system boot timings to default unvetted public pools
    # - netnod privacy policy: https://www.netnod.se/privacy-policy
    timeServers = [
      "nts.ntp.se"
      "time.cloudflare.com"
    ];

    firewall = {
      enable = true;
      # Blocks ICMP 'ping' requests from the outside
      # - Makes your machine "invisible" to basic network scanners (Stealth Mode)
      # - source: https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#icmp-variables
      allowPing = false;

      rejectPackets = true;
    };

    wireless.iwd = {
      # Uses the Intel Wireless Daemon instead of the older wpa_supplicant
      # - Faster at connecting to access points and handles MAC randomization natively
      # - wiki: https://wiki.nixos.org/wiki/Iwd
      enable = true;
      settings.General = {
        # Changes your hardware ID (MAC address) every time you connect
        # - Prevents retail surveillance systems or public Wi-Fi from logging your movements
        # - manual: https://iwd.wiki.kernel.org/
        AddressRandomization = "network";
      };
    };
  };

  boot.kernel.sysctl = {
    # TCP BBR: Improves throughput/lag on unstable Wi-Fi
    # - source: https://github.com/torvalds/linux/blob/master/net/ipv4/tcp_bbr.c
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Reverse Path Filtering
    # - Verifies that a packet arriving on an interface is coming from a reachable path to prevent IP Spoofing
    # - source: https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#proc-sys-net-ipv4
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # Disables ICMP Redirects
    # - Prevents rogue routing tables changes from a local attacker attempting Man-in-the-Middle captures
    # - source: https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#proc-sys-net-ipv4
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;

    # Disables IP Source Routing
    # - Blocks packets from forcing explicit path configurations to snake past hardware firewalls
    # - source: https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#proc-sys-net-ipv4
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;

    # Disables ICMP Echo (Ping) broadcasts
    # - Prevents your hardware node from participating in distributed Smurf amplification floods
    # - source: https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#proc-sys-net-ipv4
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };

  services.chrony = {
    enable = true;
    enableNTS = true;

    # Directs chrony to use secure, zero-log NTS servers exclusively
    servers = [
      "nts.ntp.se"
      "time.cloudflare.com"
    ];

    extraConfig = ''
      initstepslew 10 nts.ntp.se time.cloudflare.com
      allow all
    '';
  };

  services.resolved = {
    enable = true;

    # Forces DNS queries to be encrypted via TLS
    # - Prevents your upstream ISP carrier from logging which website signatures you request
    # - manual: https://www.freedesktop.org/software/systemd/man/latest/resolved.conf.html
    #
    # Sets primary DNS servers globally for the network stack
    # - Quad9 (Secure, non-profit, zero-log resolver out of Switzerland)
    # - Core Principles: Privacy by design, GDPR compliant, no commercial data selling, and built-in threat blocking
    # - ref: https://quad9.net/service/service-addresses-and-protocols
    # - policy: https://quad9.net/privacy/quad9-privacy-policy
    #
    # Sets fallback DNS servers natively
    # - Uses Cloudflare as backup routing layer
    extraConfig = "
     DNSOverTLS=yes
     MulticastDNS=no

     DNS=9.9.9.9 149.112.112.112
     FallbackDNS=1.1.1.1 1.0.0.1
    ";

    # Link-Local Multicast Name Resolution & mDNS
    # - Stops your machine from continually leaking its local hostname out onto public Wi-Fi spaces
    # - manual: https://www.freedesktop.org/software/systemd/man/latest/systemd-resolved.service.html
    llmnr = "false";

    # Drops resolution instantly if a domain's keys are broken, missing, or tampered with
    # - reading: https://www.cloudflare.com/learning/dns/dnssec/how-dnssec-works/
    dnssec = "true";

    # Routes all system DNS traffic exclusively through systemd-resolved
    # - reading: https://www.freedesktop.org/software/systemd/man/latest/systemd-resolved.service.html#Protocols%20and%20Routing
    domains = [ "~." ];
  };

  # enforce modern cryptographic standards
  services.openssh = {
    settings = {
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
      ];
      Macs = [
        "hmac-sha256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };
  };
}
