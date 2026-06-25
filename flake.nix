{
  description = "Nixos config flake - Updated 25.11";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-src = {
      url = "path:/etc/nixos/kernels/zen/latest-stable";
      flake = false;
    };
    xanmod-src = {
      url = "path:/etc/nixos/kernels/xanmod/latest-stable";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    nbfc-linux = {
      url = "github:nbfc-linux/nbfc-linux?dir=pkgbuilds/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zen-src,
      xanmod-src,
      nixvim,
      deploy-rs,
      nbfc-linux,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        blade = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [ deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs ];
              }
            )

            ./hosts/blade/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        argonone = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

            ./hosts/argonone/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/wsl/configuration.nix
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.default
          ];
        };

        live-sec = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./images/live-sec/configuration.nix
          ];
        };

        testvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./vm/test-vm.nix ];
        };
      };

      apps.x86_64-linux.run-vm = {
        type = "app";
        meta = {
          description = "Run a NixOS VM";
        };
        program =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            script = pkgs.writeShellScriptBin "run-dynamic-vm" ''
              TARGET_VM=$1

              if [ -z "$TARGET_VM" ]; then
                echo "Error: No VM configuration name provided."
                echo "Usage: nix run .#run-vm -- <config-name>"
                exit 1
              fi

              echo "Building VM configuration: $TARGET_VM..."

              VM_PATH=$(nix build .#nixosConfigurations."$TARGET_VM".config.system.build.vm --print-out-paths)

              if [ -z "$VM_PATH" ]; then
                echo "Error: Build failed or configuration '$TARGET_VM' does not exist."
                exit 1
              fi

              echo "Starting VM: $TARGET_VM..."
              sudo NIX_DISK_IMAGE=/var/lib/libvirt/images/"$TARGET_VM".qcow2 $VM_PATH/bin/run-*-vm
            '';
          in
          "${script}/bin/run-dynamic-vm";
      };

      apps.x86_64-linux.list-vms = {
        type = "app";
        meta = {
          description = "List managed VMs";
        };
        program =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;

            script = pkgs.writeShellScriptBin "list-vms" ''
              echo -e "\n=== Available Built VMs ==="

              AVAILABLE_VMS=$(sudo find /var/lib/libvirt/images -maxdepth 1 -name "*.qcow2" -exec basename {} .qcow2 \;)

              if [ -z "$AVAILABLE_VMS" ]; then
                echo "  No built VM images found."
              else
                for vm in $AVAILABLE_VMS; do
                  echo "  - $vm"
                done
              fi

              echo -e "\n=== Currently Running VMs ==="

              RUNNING_VMS=$(pgrep -a qemu-system | grep "/var/lib/libvirt/images/" | awk -F'/var/lib/libvirt/images/' '{print $2}' | awk -F'.qcow2' '{print $1}')

              if [ -z "$RUNNING_VMS" ]; then
                echo "  No VMs are currently running."
              else
                for vm in $RUNNING_VMS; do
                  echo "  - $vm (Active)"
                done
              fi
              echo ""
            '';
          in
          "${script}/bin/list-vms";
      };

      deploy = {
        nodes.argonone = {
          hostname = "192.168.178.73";
          sshUser = "dev-user";
          fastConnection = true;
          remoteBuild = true;
          profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.argonone;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
