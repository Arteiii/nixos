{ ... }:

{
  # =========================================================================
  # HARDENED BASELINE WRAPPER
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  imports = [
    ./system.nix
    ./networking.nix
    ../cleanup.nix
    ../upgrade.nix
    ./thunderbird.nix
  ];
}
