{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    inputs.nbfc-linux.packages.x86_64-linux.default
  ];

  systemd.services.nbfc_service = {
    enable = true;
    description = "NoteBook FanControl service (JSON-Mode)";

    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.nbfc-linux.packages.x86_64-linux.default}/bin/nbfc_service --auto-fan-control";
      Restart = "always";
      RestartSec = "5";
    };

    path = [ pkgs.kmod ];

    wantedBy = [ "multi-user.target" ];
  };
}
