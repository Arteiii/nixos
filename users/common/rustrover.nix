{ pkgs, ... }:

{
  home.packages = [
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover [
      "nixidea"
    ])
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
