{ pkgs, ... }:
{

  home.packages = [ pkgs.libsecret ];

  services.protonmail-bridge = {
    enable = true;
  };

  systemd.user.startServices = "sd-switch";

  services.gnome-keyring.enable = true;

  accounts.email.accounts.proton = {
    primary = true;
    address = "bpilger@sparx.foundation";
    realName = "Ben Pilger";
    userName = "bpilger@sparx.foundation";

    passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup service protonmail-bridge account local-pass";

    imap = {
      host = "127.0.0.1";
      port = 1143;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };

    smtp = {
      host = "127.0.0.1";
      port = 1025;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };

    thunderbird.enable = true;

    msmtp = {
      enable = true;
      extraConfig = {
        tls_certcheck = "off";
      };
    };
    neomutt.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      withExternalGnupg = true;

      settings = {
        "signon.rememberSignons" = true;
      };
    };
  };

  programs.msmtp.enable = true;

  programs.neomutt = {
    enable = true;
    sidebar.enable = true;

    extraConfig = ''
      set edit_headers=yes

      color body green default "^\\+.*"
      color body red default "^-.*"
    '';
  };
}
