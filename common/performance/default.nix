{ ... }:

{
  # =========================================================================
  # PERFORMANCE BASELINE WRAPPER
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  imports = [
    ./system.nix
    ./networking.nix
    ./hardware.nix
    ../cleanup.nix
    ../upgrade.nix
  ];
}
