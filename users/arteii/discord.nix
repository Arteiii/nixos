{ pkgs, ... }:

{
  programs.discord = {
    enable = true;

    package = pkgs.discord;
  };
}
