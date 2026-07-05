{ ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./public.bpilger-sparx-foundation.asc;
        trust = 5;
      }
    ];
  };
}
