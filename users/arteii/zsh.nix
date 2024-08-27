{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "amuse";
    };

    initExtra = ''
      alias ll='ls -lah'
      alias la='ls -A'
      alias l='ls -CF'

      setopt correct

      setopt extendedglob

      autoload -Uz compinit && compinit
      bindkey '^R' history-incremental-search-backward

      HISTSIZE=1000
      SAVEHIST=1000
      HISTFILE=~/.zsh_history

      if [[ -n $SSH_CONNECTION ]]; then
        export EDITOR='vim'
      else
        export EDITOR='nano'
      fi

      export PATH=$HOME/bin:/usr/local/bin:$PATH
    '';
  };

  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-syntax-highlighting
  ];
}

