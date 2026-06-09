{ ... }:

{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks."*" = {
      identityFile = [
        "~/.ssh/id_ed25519"
      ];
      forwardAgent = false;
    };

    extraConfig = ''
      ControlMaster auto
      ControlPath ~/.ssh/sockets/%r@%h-%p
      ControlPersist 10m
    '';
  };

  home.file.".ssh/sockets/.keep".text = "";
}
