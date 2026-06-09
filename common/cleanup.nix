{ lib, ... }:

{
  # =========================================================================
  # MAINTENANCE & STORAGE OPTIMIZATION
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  nix = {
    settings = {
      # Deduplicates identical files in the Nix store automatically to save disk space
      # ref: https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
      auto-optimise-store = lib.mkDefault true;

      # Automatically wipes out unreferenced builds daily
      min-free = 5368709120; # 5 GB down to keep space safe
    };

    # safely dedupicates store every night
    optimise = {
      automatic = true;
    };

    # Periodically clears out old generations and unused packages
    # ref: https://nixos.org/manual/nixos/stable/options#opt-nix.gc.automatic
    gc = {
      automatic = lib.mkDefault true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Cap the binary systemd journal size to prevent heavy processing overhead
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    MaxRetentionSec=1month
    SystemKeepFree=1G
  '';

  services.logrotate = {
    enable = true;
    settings = {
      "/var/log/wtmp" = {
        rotate = 2;
        frequency = "weekly";
        maxsize = "1M";
        create = "0664 root utmp";
      };
      "/var/log/btmp" = {
        rotate = 1;
        frequency = "weekly";
        maxsize = "500k";
        create = "0600 root utmp";
      };
    };
  };

  # clear legacy garbage instantly on boot (lightens systemd-tmpfiles-setup.service)
  boot.tmp.cleanOnBoot = true;
}
