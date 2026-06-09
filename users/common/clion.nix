{ pkgs, ... }:

{
  home.packages = [
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.clion [
      "nixidea"
    ])
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
