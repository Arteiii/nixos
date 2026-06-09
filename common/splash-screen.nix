{ pkgs, ... }:

{
  console = {
    enable = true;
    earlySetup = true;
  };

  boot = {
    initrd.kernelModules = [ ];
    initrd.verbose = false;

    plymouth = {
      enable = true;
      theme = "deus_ex";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "deus_ex" ];
        })
      ];
      extraConfig = ''
        [Daemon]
        ShowDelay=0
        DeviceTimeout=5
      '';
    };
  };

  # Appends the graphical activation tag to the kernel array
  boot.kernelParams = [
    "splash"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "quiet"
    "loglevel=0"
    "vt.global_cursor_default=0"
  ];
}
