{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

{
  programs.ccache = {
    enable = true;
    packageNames = [
      "ffmpeg"
      "mesa"
    ];
  };
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  nixpkgs.overlays = [
    (final: prev: {
      ccacheWrapper = prev.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          export HOME="$TMPDIR"
        '';
      };

      myCustomZen = prev.linuxPackagesFor (
        prev.linuxKernel.kernels.linux_zen.override {
          stdenv = final.ccacheStdenv;

          argsOverride = {
            src = inputs.zen-src;
            modDirVersion = "7.0.9-zen";
          };

          structuredExtraConfig = with lib.kernel; {
            MODULE_COMPRESS_ZSTD_LEVEL = freeform "1";

            DEBUG_INFO = no;
            DEBUG_KERNEL = no;
            DEBUG_MISC = no;
            CRASH_DUMP = no;
          };

          ignoreConfigErrors = true;
        }
      );
    })
  ];

  boot.kernelPackages = pkgs.myCustomZen;
}
