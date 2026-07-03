{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      ControlMaster = "auto";
      ControlPath = "~/.ssh/sockets/%r@%h-%p";
      ControlPersist = "10m";
    };

    matchBlocks = {
      "*" = {
        identityFile = [
          "~/.ssh/id_ed25519"
        ];
        forwardAgent = false;
      };
    };
  };

  home.file.".ssh/sockets/.keep".text = "";
}
