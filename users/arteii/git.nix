{ pkgs, ... }:

{
  home.packages = [ pkgs.vim-full ];

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Ben Pilger";
        email = "bpilger@sparx.foundation";
      };

      sendemail = {
        smtpserver = "${pkgs.msmtp}/bin/msmtp";
        smtpserveroption = "-t";
      };

      gpg.format = "ssh";
      "gpg.ssh".defaultKeyCommand = "ssh-add -L";

      commit.gpgsign = true;

      signing = {
        signByDefault = true;
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
