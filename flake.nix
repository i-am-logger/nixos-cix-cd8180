{
  description = "NixOS configuration for CIX CD8180/CD8160 SoC boards";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "i-am-logger.cachix.org-1:wGCjEpWzIVhSWh0Pe+3VbIvecLaUIhjaWx5vjXzWUOE="
    ];
    extra-substituters = [
      "https://i-am-logger.cachix.org"
    ];
    extra-sandbox-paths = [
      "/tmp/ccache"
    ];
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , nixos-generators
    , ...
    } @ inputs:
    let
      localSystem = "x86_64-linux";
      pkgsLocal = import nixpkgs { system = localSystem; };

      aarch64System = "aarch64-linux";

      # Native aarch64 packages with CIX CD8180/CD8160 overlays
      pkgsNative = import nixpkgs {
        system = aarch64System;
        overlays = [ self.overlays.default ];
      };

      # Cross-compiled packages with CIX CD8180/CD8160 overlays
      pkgsCross = import nixpkgs {
        inherit localSystem;
        crossSystem = aarch64System;
        overlays = [ self.overlays.default ];
      };
    in
    {
      overlays = {
        # Vendor kernels for CIX CD8180/CD8160
        cixSky1Kernels = final: prev: (import ./pkgs/kernel { pkgs = prev; });

        # CIX CD8180/CD8160 drivers and firmware (SoC-specific)
        cixSky1Drivers = final: prev: {
          cix-gpu-umd = final.callPackage ./pkgs/drivers/gpu { };
          cix-npu-umd = final.callPackage ./pkgs/drivers/npu { };
          cix-isp-umd = final.callPackage ./pkgs/drivers/isp { };
          cix-vpu-firmware = (final.callPackage ./pkgs/drivers/vpu { }).vpu-firmware;
          cix-firmware = final.callPackage ./pkgs/firmware { };
          cix-tools = final.callPackage ./pkgs/cix-tools { };
        };

        # Combined overlay for convenience
        default = final: prev:
          (self.overlays.cixSky1Kernels final prev) //
          (self.overlays.cixSky1Drivers final prev);
      };

      nixosModules = {
        # Board-specific modules
        orangepi6plus = {
          default = ./modules/boards/orangepi6plus;
          sdImage = ./modules/sd-image;
          netboot = ./modules/boards/orangepi6plus/netboot.nix;
        };

        # Board module with overlay (for user configurations)
        boards = {
          orangepi6plus = { config, pkgs, lib, ... }: {
            imports = [ ./modules/boards/orangepi6plus ];
            nixpkgs.overlays = [ self.overlays.default ];
            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
              "cix-gpu-umd"
              "cix-npu-umd"
              "cix-isp-umd"
              "cix-vpu-firmware"
              "cix-firmware"
              "cix-tools"
            ];
          };
        };

        kernel = {
          vendor = import ./pkgs/kernel/vendor.nix;
          mainline = import ./pkgs/kernel/mainline.nix;
        };

        drivers = {
          gpu = import ./pkgs/drivers/gpu;
          npu = import ./pkgs/drivers/npu;
          isp = import ./pkgs/drivers/isp;
          vpu = import ./pkgs/drivers/vpu;
        };

        firmware = import ./pkgs/firmware;
      };

      nixosConfigurations = {
        orangepi6plus = nixpkgs.lib.nixosSystem {
          system = aarch64System;
          specialArgs = {
            cixSky1 = {
              inherit nixpkgs;
              pkgsKernel = pkgsNative;
            };
          };
          modules = [
            ./modules/configuration.nix
            self.nixosModules.boards.orangepi6plus
            self.nixosModules.orangepi6plus.sdImage
            {
              networking.hostName = "orangepi6plus";
            }
          ];
        };

        orangepi6plus-cross = nixpkgs.lib.nixosSystem {
          specialArgs = {
            cixSky1 = {
              inherit nixpkgs;
              pkgsKernel = pkgsCross;
            };
          };
          modules = [
            ./modules/configuration.nix
            self.nixosModules.boards.orangepi6plus
            self.nixosModules.orangepi6plus.sdImage
            {
              networking.hostName = "orangepi6plus";
              nixpkgs.buildPlatform = localSystem;
              nixpkgs.hostPlatform = aarch64System;
            }
          ];
        };

        orangepi6plus-netboot = nixpkgs.lib.nixosSystem {
          system = aarch64System;
          specialArgs = {
            cixSky1 = {
              inherit nixpkgs;
              pkgsKernel = pkgsNative;
            };
          };
          modules = [
            ./modules/configuration.nix
            self.nixosModules.boards.orangepi6plus
            self.nixosModules.orangepi6plus.netboot
            {
              networking.hostName = "orangepi6plus";
            }
          ];
        };

        orangepi6plus-netboot-cross = nixpkgs.lib.nixosSystem {
          system = localSystem;
          specialArgs = {
            cixSky1 = {
              inherit nixpkgs;
              pkgsKernel = pkgsCross;
            };
          };
          modules = [
            ./modules/configuration.nix
            self.nixosModules.boards.orangepi6plus
            self.nixosModules.orangepi6plus.netboot
            {
              networking.hostName = "orangepi6plus";
              nixpkgs.buildPlatform = localSystem;
              nixpkgs.hostPlatform = aarch64System;
            }
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      # Package sets with unfree allowed for firmware/tools
      pkgsNativeUnfree = import nixpkgs {
        system = aarch64System;
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };

      pkgsCrossUnfree = import nixpkgs {
        localSystem = system;
        crossSystem = aarch64System;
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      packages = {
        # SoC-level packages (CIX Sky1 - works on any Sky1 board)
        kernel = self.nixosConfigurations.orangepi6plus.config.boot.kernelPackages.kernel;
        kernel-cross = self.nixosConfigurations.orangepi6plus-cross.config.boot.kernelPackages.kernel;

        drivers = self.nixosConfigurations.orangepi6plus.config.system.build.modulesClosure;
        drivers-cross = self.nixosConfigurations.orangepi6plus-cross.config.system.build.modulesClosure;

        firmware = pkgsNativeUnfree.cix-firmware;
        firmware-cross = pkgsCrossUnfree.cix-firmware;

        tools = pkgsNativeUnfree.cix-tools;
        tools-cross = pkgsCrossUnfree.cix-tools;

        # Board-specific packages (Orange Pi 6 Plus)
        # Naming: boards-orangepi6plus-{type}[-cross]
        boards-orangepi6plus-sdImage = self.nixosConfigurations.orangepi6plus.config.system.build.sdImage;
        boards-orangepi6plus-sdImage-cross = self.nixosConfigurations.orangepi6plus-cross.config.system.build.sdImage;

        boards-orangepi6plus-netboot = pkgs.runCommand "netboot-orangepi6plus" { } ''
          mkdir -p $out
          ln -s ${self.nixosConfigurations.orangepi6plus-netboot.config.system.build.kernel}/Image $out/kernel
          ln -s ${self.nixosConfigurations.orangepi6plus-netboot.config.system.build.netbootRamdisk}/initrd $out/initrd
          ln -s ${self.nixosConfigurations.orangepi6plus-netboot.config.system.build.netbootIpxeScript}/netboot.ipxe $out/netboot.ipxe
        '';

        boards-orangepi6plus-netboot-cross = pkgs.runCommand "netboot-orangepi6plus-cross" { } ''
          mkdir -p $out
          ln -s ${self.nixosConfigurations.orangepi6plus-netboot-cross.config.system.build.kernel}/Image $out/kernel
          ln -s ${self.nixosConfigurations.orangepi6plus-netboot-cross.config.system.build.netbootRamdisk}/initrd $out/initrd
          ln -s ${self.nixosConfigurations.orangepi6plus-netboot-cross.config.system.build.netbootIpxeScript}/netboot.ipxe $out/netboot.ipxe
        '';

        # Board tools: orangepi-config + wiringop combined
        boards-orangepi6plus-tools = pkgs.symlinkJoin {
          name = "orangepi6plus-tools";
          paths = [
            (pkgsNativeUnfree.callPackage ./pkgs/orangepi-config { })
            (pkgsNativeUnfree.callPackage ./pkgs/wiringop { })
          ];
        };

        boards-orangepi6plus-tools-cross = pkgs.symlinkJoin {
          name = "orangepi6plus-tools-cross";
          paths = [
            (pkgsCrossUnfree.callPackage ./pkgs/orangepi-config { })
            (pkgsCrossUnfree.callPackage ./pkgs/wiringop { })
          ];
        };
      };

      devShells.default = pkgs.mkShell {
        name = "nixos-cix-cd8180-dev";
        packages = with pkgs; [
          git
          cachix
          nix-prefetch-github
          nixpkgs-fmt
        ];
        shellHook = ''
          echo "NixOS CIX CD8180/CD8160 (Sky1) Development Environment"
          echo ""
          echo "Available commands:"
          echo "  nix flake check       - Check flake"
          echo "  nixpkgs-fmt --check . - Check formatting"
          echo "  nixpkgs-fmt .         - Format all .nix files"
          echo "  nix build .#sdImage   - Build SD image"
          echo "  cachix push           - Push to cache"
        '';
      };

      devShells.kernel = pkgs.mkShell {
        name = "kernel-build-env";
        packages = with pkgs; [
          pkg-config
          ncurses
          pkgsCross.gccStdenv.cc
          gcc
          bc
          bison
          flex
          openssl
          perl
          python3
          dtc
        ] ++ pkgs.linux.nativeBuildInputs;

        shellHook = ''
          export CROSS_COMPILE=aarch64-unknown-linux-gnu-
          export ARCH=arm64
          export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:"
          echo "Kernel development environment for CIX CD8180/CD8160"
          echo "ARCH=$ARCH"
          echo "CROSS_COMPILE=$CROSS_COMPILE"
        '';
      };
    });
}
