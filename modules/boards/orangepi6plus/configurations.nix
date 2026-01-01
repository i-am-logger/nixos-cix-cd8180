# NixOS configurations and module for Orange Pi 6 Plus
# Provides nixosModule, SD image, netboot, and cross-compilation variants
{ nixpkgs, socOverlays, pkgs ? null, pkgsNativeUnfree ? null, pkgsCrossUnfree ? null, ... }:

let
  localSystem = "x86_64-linux";
  aarch64System = "aarch64-linux";

  # Native aarch64 packages
  pkgsNative = import nixpkgs {
    system = aarch64System;
    overlays = [ socOverlays.default ];
  };

  # Cross-compiled packages
  pkgsCross = import nixpkgs {
    inherit localSystem;
    crossSystem = aarch64System;
    overlays = [ socOverlays.default ];
  };

  # Import unfree predicate from lib
  unfree = import ../../../lib/unfree.nix { lib = nixpkgs.lib; };
  allowUnfreePredicate = unfree.allowCixSky1Unfree;

  # Helper to create netboot package with standardized naming
  # Pattern: nixos-{board}-netboot-{version}-{arch}.tar.gz
  # Creates a tarball containing kernel, initrd, and iPXE script
  mkNetbootPackage = cfg:
    let
      board = cfg.config.networking.hostName;
      version = cfg.config.system.nixos.version;
      arch = cfg.config.nixpkgs.hostPlatform.system;
      name = "nixos-${board}-netboot-${version}-${arch}";
      tarballName = "${name}.tar.gz";
    in
    pkgs.runCommand name { nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ]; } ''
      # Create temporary directory for netboot files
      mkdir -p netboot
      cp ${cfg.config.system.build.kernel}/Image netboot/kernel
      cp ${cfg.config.system.build.netbootRamdisk}/initrd netboot/initrd
      cp ${cfg.config.system.build.netbootIpxeScript}/netboot.ipxe netboot/netboot.ipxe
      
      # Create tarball
      mkdir -p $out
      tar -czf "$out/${tarballName}" -C netboot .
      
      # Also symlink individual files for compatibility
      ln -s ${cfg.config.system.build.kernel}/Image $out/kernel
      ln -s ${cfg.config.system.build.netbootRamdisk}/initrd $out/initrd
      ln -s ${cfg.config.system.build.netbootIpxeScript}/netboot.ipxe $out/netboot.ipxe
    '';
in
rec {
  # User-facing NixOS module
  module = import ./module.nix socOverlays;

  # Build configurations
  configurations = {
    # Native aarch64 build with SD image
    orangepi6plus = nixpkgs.lib.nixosSystem {
      system = aarch64System;
      specialArgs = {
        cixSky1 = {
          inherit nixpkgs;
          pkgsKernel = pkgsNative;
        };
      };
      modules = [
        ../../configuration.nix
        ./hardware.nix
        ../../sd-image
        {
          nixpkgs.overlays = [ socOverlays.default ];
          nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
          networking.hostName = "orangepi6plus";
        }
      ];
    };

    # Cross-compiled from x86_64 with SD image
    orangepi6plus-cross = nixpkgs.lib.nixosSystem {
      specialArgs = {
        cixSky1 = {
          inherit nixpkgs;
          pkgsKernel = pkgsCross;
        };
      };
      modules = [
        ../../configuration.nix
        ./hardware.nix
        ../../sd-image
        {
          nixpkgs.overlays = [ socOverlays.default ];
          nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
          networking.hostName = "orangepi6plus";
          nixpkgs.buildPlatform = localSystem;
          nixpkgs.hostPlatform = aarch64System;
        }
      ];
    };

    # Native aarch64 netboot
    orangepi6plus-netboot = nixpkgs.lib.nixosSystem {
      system = aarch64System;
      specialArgs = {
        cixSky1 = {
          inherit nixpkgs;
          pkgsKernel = pkgsNative;
        };
      };
      modules = [
        ../../configuration.nix
        ./hardware.nix
        ./netboot.nix
        {
          nixpkgs.overlays = [ socOverlays.default ];
          nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
          networking.hostName = "orangepi6plus";
        }
      ];
    };

    # Cross-compiled netboot
    orangepi6plus-netboot-cross = nixpkgs.lib.nixosSystem {
      system = localSystem;
      specialArgs = {
        cixSky1 = {
          inherit nixpkgs;
          pkgsKernel = pkgsCross;
        };
      };
      modules = [
        ../../configuration.nix
        ./hardware.nix
        ./netboot.nix
        {
          nixpkgs.overlays = [ socOverlays.default ];
          nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
          networking.hostName = "orangepi6plus";
          nixpkgs.buildPlatform = localSystem;
          nixpkgs.hostPlatform = aarch64System;
        }
      ];
    };
  };

  # Packages (only if pkgs is provided)
  packages =
    if pkgs != null then {
      orangepi6plus-sdImage = configurations.orangepi6plus.config.system.build.sdImage;
      orangepi6plus-sdImage-cross = configurations.orangepi6plus-cross.config.system.build.sdImage;

      orangepi6plus-netboot = mkNetbootPackage configurations.orangepi6plus-netboot;
      orangepi6plus-netboot-cross = mkNetbootPackage configurations.orangepi6plus-netboot-cross;

      orangepi6plus-tools = pkgs.symlinkJoin {
        name = "orangepi6plus-tools";
        paths = [
          (pkgsNativeUnfree.callPackage ../../../pkgs/orangepi-config { })
          (pkgsNativeUnfree.callPackage ../../../pkgs/wiringop { })
        ];
      };

      orangepi6plus-tools-cross = pkgs.symlinkJoin {
        name = "orangepi6plus-tools-cross";
        paths = [
          (pkgsCrossUnfree.callPackage ../../../pkgs/orangepi-config { })
          (pkgsCrossUnfree.callPackage ../../../pkgs/wiringop { })
        ];
      };
    } else { };
}
