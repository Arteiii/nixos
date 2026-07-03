{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "10m";

        IdentityFile = "~/.ssh/id_ed25519";
        ForwardAgent = "no";
      };
    };
  };

  home.file.".ssh/sockets/.keep".text = "";
}
