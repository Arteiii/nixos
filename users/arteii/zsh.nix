{ pkgs, ... }:

{
  imports = [
    ../common/cli.nix
  ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    powerline-fonts
    powerline-symbols

    zsh
    oh-my-zsh
    zsh-syntax-highlighting
  ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "amuse";
    };
  };
}
