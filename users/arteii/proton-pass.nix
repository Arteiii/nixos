{ pkgs, ... }:

{

  home.packages = [ pkgs.proton-pass ];

  # systemd.user.services.proton-pass-agent = {
  #   Unit = {
  #     Description = "Proton Pass SSH Agent";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.proton-pass}/bin/pass-cli ssh-agent start --socket-path %h/.ssh/proton-pass-agent.sock";
  #     Restart = "always";
  #   };
  # };
}
