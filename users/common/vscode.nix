{ pkgs, ... }:

{
  home.packages = [
    pkgs.nil
    pkgs.nixfmt
  ];

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        yzhang.markdown-all-in-one
        esbenp.prettier-vscode
        rust-lang.rust-analyzer
        llvm-vs-code-extensions.vscode-clangd
      ];
      userSettings = {
        "files.autoSave" = "onFocusChange";
        "editor.formatOnSave" = true;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
          };
        };

        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[rust]" = {
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
        };
        "[c]" = {
          "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
        };
        "[cpp]" = {
          "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
        };
      };
    };
  };
}
