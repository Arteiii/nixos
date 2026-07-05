{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cargo
    rustc
    rust-analyzer
    clippy
    rustfmt

    gcc
    gnumake
    cmake
    gdb
    lldb
    pkg-config

    openssl
    openssl.dev
    zlib
  ];

  # fixes nixos dependencies for cargo and co
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
