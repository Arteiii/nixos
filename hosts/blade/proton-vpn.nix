{ pkgs, ... }:

{
  systemd.services.protonvpn-namespace = {
    description = "ProtonVPN Namespace & WireGuard Tunnel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];

    path = with pkgs; [
      iproute2
      wireguard-tools
      libnotify
      util-linux
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = pkgs.writeShellScript "start-proton-vpn" ''
        CONFIG=$(ls /home/arteii/proton-configs/*.conf | shuf -n 1)

        parse_key() {
          grep -v "^#" "$CONFIG" | grep "$1" | sed -E "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//" | tr -d '\r' | head -n 1
        }

        ENDPOINT=$(parse_key "Endpoint")
        PRIVATE_KEY=$(parse_key "PrivateKey")
        PEER_KEY=$(parse_key "PublicKey")
        ADDRESS=$(parse_key "Address")

        ip netns del protonvpn 2>/dev/null || true
        ip link del proton0 2>/dev/null || true

        set -e

        ip netns add protonvpn
        ip -n protonvpn link set lo up

        ip link add proton0 type wireguard

        wg set proton0 \
          private-key <(echo "$PRIVATE_KEY") \
          peer "$PEER_KEY" \
          endpoint "$ENDPOINT" \
          allowed-ips 0.0.0.0/0 \
          persistent-keepalive 25
                     
        ip link set proton0 netns protonvpn

        ip -n protonvpn address add 10.2.0.2/32 dev proton0
        ip -n protonvpn link set proton0 up

        ip -n protonvpn route add default dev proton0
      '';

      ExecStop = pkgs.writeShellScript "stop-proton-vpn" ''
        ip netns del protonvpn || true
      '';
    };
  };
}
