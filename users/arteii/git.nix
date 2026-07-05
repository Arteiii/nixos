{ pkgs, ... }:

{
  home.packages = [ pkgs.vim-full ];

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;

    signing = {
      signByDefault = true;
      format = "openpgp";
    };

    settings = {
      user = {
        name = "Ben Pilger";
        email = "bpilger@sparx.foundation";
        signingKey = "94BA92822B22C7746900BD0E1A3EA9A6B60C37DA";
      };

      sendemail = {
        smtpserver = "${pkgs.msmtp}/bin/msmtp";
        smtpserveroption = "-t";
      };

      commit = {
        gpgsign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
      };

      push = {
        autoSetupRemote = true;
      };

      init.defaultBranch = "main";
      core.editor = "vim";

      alias = {
        c = "commit -s -S";
      };

      merge.conflictstyle = "diff3";
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "dist/"
      "node_modules/"
      ".direnv/"
    ];
  };
}
