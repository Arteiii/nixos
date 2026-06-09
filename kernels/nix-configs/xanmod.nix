{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

{
  system.nixos.tags = [ "XanMod-Testing" ];

  programs.ccache.enable = true;
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  systemd.tmpfiles.rules = [
    "d ${config.programs.ccache.cacheDir} 0770 root nixbld - -"
  ];

  boot.initrd.allowMissingModules = true;

  nixpkgs.overlays = [
    (final: prev: {
      ccacheWrapper = prev.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          export HOME="$TMPDIR"
          # Avoid cache misses caused by Nix's randomized build hashes
          export CCACHE_SLOPPINESS=random_seed
        '';
      };

      makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

      myCustomXanmod = prev.linuxPackagesFor (
        prev.linuxKernel.kernels.linux_xanmod.override {
          # stops unecessary file generation
          autoModules = false;

          stdenv = final.stdenvAdapters.addAttrsToDerivation {
            env.KCFLAGS = "-march=native -O2";
            env.KCPPFLAGS = "-march=native -O2";
          } final.ccacheStdenv;

          buildPackages = final.buildPackages // {
            stdenv = final.stdenvAdapters.addAttrsToDerivation {
              env.KCFLAGS = "-march=native -O2";
              env.KCPPFLAGS = "-march=native -O2";
            } final.buildPackages.ccacheStdenv;
          };

          argsOverride = {
            src = inputs.xanmod-src;
            modDirVersion = "7.0.9-xanmod1";
          };

          structuredExtraConfig = with lib.kernel; {
            MODULE_COMPRESS_ZSTD_LEVEL = freeform "1";
            DEBUG_INFO = no;
            DEBUG_KERNEL = no;
            DEBUG_MISC = no;
            CRASH_DUMP = no;

            # filesystem
            BLK_DEV_NVME = yes;
            BLK_DEV_DM = yes;
            DM_CRYPT = yes;
            BTRFS_FS = yes;

            # hardware support
            USB_SUPPORT = yes;
            USB_XHCI_HCD = yes;
            USB_XHCI_PCI = yes;

            # core crypto hardware support
            CRYPTO_AES = yes;
            CRYPTO_AES_NI_INTEL = yes;
            CRYPTO_CRYPTD = yes;
            CRYPTO_XTS = yes;
            CRYPTO_SHA256 = yes;

            # user space crypto support
            CRYPTO_USER_API = yes;
            CRYPTO_USER_API_ALG = yes;
            CRYPTO_USER_API_HASH = yes;
            CRYPTO_USER_API_SKCIPHER = yes;

            CONFIG_X86_KERNEL_IBT = y;
          };

          ignoreConfigErrors = true;
        }
      );
    })
  ];

  boot.kernelPackages = pkgs.myCustomXanmod;
}
