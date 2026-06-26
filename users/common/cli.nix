{ pkgs, config, ... }:

let
  flakePath = "/etc/nixos";

  rebuildScript = action: ''
    (
      cd ${flakePath} || return
      git checkout dev 2>/dev/null || git checkout -b dev
      git add .
      git commit -m "nixos-${action}: auto-commit $(date '+%Y-%m-%d %H:%M:%S')"
      sudo nixos-rebuild ${action} --flake .#"$HOSTNAME"
    )
  '';

  initContent = ''
    export EDITOR='vim'

    if command -v direnv &> /dev/null; then
      eval "$(direnv hook ''${SHELL##*/})"
    fi

    export PATH=$HOME/bin:/usr/local/bin:$PATH

    echo -e "\033[1;36m=================== ARTEII CLI ENV ===================\033[0m"
    echo -e " \033[1;35mConfig Reference:\033[0m github.com/arteiii/nixos"
    echo ""
    echo -e " \033[1;32mFile Navigation (eza & zoxide):\033[0m"
    echo -e "   ls / ll / la    \033[0;33m->\033[0m List files (Standard / Long layout / Hidden files)"
    echo -e "   tree            \033[0;33m->\033[0m Recursive directory tree view"
    echo -e "   cd [dir]        \033[0;33m->\033[0m Smart jump to any tracked folder via fuzzy name"
    echo -e "   zi / zb         \033[0;33m->\033[0m Interactive folder search via fzf / Back to last dir"
    echo -e " \033[1;32mFile Utilities (bat & ripgrep):\033[0m"
    echo -e "   cat [file]      \033[0;33m->\033[0m View file with syntax highlighting & line numbers"
    echo -e "   rg [pattern]    \033[0;33m->\033[0m Binary-fast plaintext search across codebases"
    echo -e " \033[1;32mGit Shortcuts:\033[0m"
    echo -e "   gs / ga / gc    \033[0;33m->\033[0m git status / git add / git commit -m"
    echo -e "   gp / gl         \033[0;33m->\033[0m git push / git log --oneline"

    if command -v nixos-rebuild &> /dev/null; then
      echo -e " \033[1;32mNixOS Management:\033[0m"
      echo -e "   nswitch         \033[0;33m->\033[0m Git auto-commit & system switch (#$HOSTNAME)"
      echo -e "   nboot           \033[0;33m->\033[0m Git auto-commit & system boot (#$HOSTNAME)"
      echo ""
      echo -e " \033[1;32mVirtual Machines:\033[0m"
      echo -e "   vm-list         \033[0;33m->\033[0m List all built and active VMs"
      echo -e "   vm-run [name]   \033[0;33m->\033[0m Build and launch a VM"
    fi

    echo -e " \033[1;32mProject Management:\033[0m"
    echo -e "   mk-env          \033[0;33m->\033[0m Create .envrc (use flake) & allow environment"
    echo ""

    if systemctl list-unit-files | grep -q "iwd.service"; then
      echo -e " \033[1;32mWireless Network:\033[0m"
      echo -e "   wifi-on         \033[0;33m->\033[0m Start iwd daemon & enable Wi-Fi in GNOME"
      echo -e "   wifi-off        \033[0;33m->\033[0m Stop iwd daemon & disable Wi-Fi in GNOME"
    fi

    echo -e " \033[1;32mSystem Performance:\033[0m"
    echo -e "   htop            \033[0;33m->\033[0m Interactive terminal process & resource monitor"
    echo -e "\033[1;36m=====================================================\033[0m"
    echo ""
  '';
in
{
  home.packages = with pkgs; [
    eza # Modern replacement for 'ls'
    bat # Modern replacement for 'cat' with syntax highlighting
    fzf # Command-line fuzzy finder
    ripgrep # Ultra-fast alternative to 'grep'
    zoxide # Smarter 'cd' command that remembers your paths
    htop # Interactive process viewer
    imhex # Hex Editor
    fastfetch # welllll....
    gh # GitHub CLI
    jq # cli json parser
    fzf
    tldr # cleaner man page
    git
    zsh
  ];

  # automatically applies these to both Bash and Zsh system-wide
  home.shellAliases = {
    # eza / ls aliases
    ls = "eza --icons --group-directories-first";
    ll = "eza -lh --icons --group-directories-first";
    la = "eza -lah --icons --group-directories-first";
    tree = "eza --tree --icons";

    # bat / cat aliases
    cat = "bat";

    # Git shortcuts
    gs = "git status";
    ga = "git add";
    gc = "git commit -m";
    gp = "git push";
    gl = "git log --oneline";

    # nix helpers
    mk-env = "echo 'use flake' > .envrc && direnv allow";

    # VM helpers
    vm-list = "nix run ${flakePath}#list-vms";
    vm-run = "nix run ${flakePath}#run-vm --";

    # Zoxide helpers
    zi = "cdi";
    zb = "cd -";

    nswitch = "nixos-switch";
    nboot = "nixos-boot";

    wifi-on = "sudo systemctl start iwd && dconf write /org/gnome/desktop/privacy/disable-wifi false";
    wifi-off = "sudo systemctl stop iwd && dconf write /org/gnome/desktop/privacy/disable-wifi true";
  };

  home.sessionVariables = {
    # Passe den Pfad an dein Btrfs-Mountpoint an
    CCACHE_DIR = "/var/cache/ccache";
  };

  programs.zsh.initContent = pkgs.lib.mkIf config.programs.zsh.enable ''
    nixos-switch() { ${rebuildScript "switch"} }
    nixos-boot() { ${rebuildScript "boot"} }
    ${initContent}
  '';

  programs.bash.initExtra = pkgs.lib.mkIf config.programs.bash.enable ''
    nixos-switch() { ${rebuildScript "switch"} }
    nixos-boot() { ${rebuildScript "boot"} }
    ${initContent}
  '';

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
