{
  inputs,
  pkgs,
  ...
}:
let
  nbfcConfig = builtins.toJSON {
    notebook_model = "Razer Blade";
    fan_configurations = [
      {
        fan_speed_write_cycles = 100;
        read_write_cycles = 100;
        temperature_thresholds = [
          {
            temperature = 35;
            fan_speed = 40;
          }
          {
            temperature = 45;
            fan_speed = 60;
          }
          {
            temperature = 55;
            fan_speed = 85;
          }
          {
            temperature = 65;
            fan_speed = 100;
          }
        ];
      }
    ];
  };
in
{

  environment.etc."nbfc.json".text = nbfcConfig;

  environment.systemPackages = [
    inputs.nbfc-linux.packages.x86_64-linux.default
  ];
  systemd.services.nbfc_service = {
    enable = true;
    description = "NoteBook FanControl service (JSON-Mode)";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.nbfc-linux.packages.x86_64-linux.default}/bin/nbfc_service --config-file /etc/nbfc.json";
      Restart = "always";
    };
    path = [ pkgs.kmod ];
    wantedBy = [ "multi-user.target" ];
  };
}
