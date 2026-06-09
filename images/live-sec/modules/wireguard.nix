{ pkgs, ... }:
let
  select-vpn = pkgs.writeShellScriptBin "select-vpn" ''
    CONFIG_DIR="/persist/wg-configs"
    if ! mountpoint -q /persist; then
        echo "Fehler: /persist nicht gemountet. Erst 'unlock-storage' nutzen."
        exit 1
    fi
    SELECTED=$(${pkgs.fzf}/bin/fzf --prompt="Wähle VPN-Server: " < <(ls $CONFIG_DIR/*.conf))
    if [ -n "$SELECTED" ]; then
        sudo systemctl stop wg-quick-wg0
        sudo cp "$SELECTED" /etc/wireguard/wg0.conf
        sudo systemctl start wg-quick-wg0
    fi
  '';
in
{
  environment.systemPackages = [ select-vpn ];

  networking.firewall = {
    enable = true;
    # kll switch
    extraCommands = ''
      iptables -P OUTPUT DROP
      iptables -A OUTPUT -o lo -j ACCEPT
      iptables -A OUTPUT -o wg0 -j ACCEPT
      iptables -A OUTPUT -p udp --dport 51820 -j ACCEPT
    '';
  };

  networking.wireguard.interfaces.wg0 = {
    dns = [ "9.9.9.9" ];
  };

  # no auto start
  systemd.services.wg-quick-wg0.wantedBy = [ ];
}
