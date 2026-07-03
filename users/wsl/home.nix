{ pkgs, ... }:

{
  home.username = "nixos";
  home.stateVersion = "26.05";

  imports = [
    ../../users/arteii/git.nix
    ../../users/common/cli.nix
  ];

  home.packages = with pkgs; [
    sops
    age
  ];

  programs.zsh.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
