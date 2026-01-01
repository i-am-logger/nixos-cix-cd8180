# Sky1 SoC configuration
# Used to build SoC-level packages (kernel, drivers) for all Sky1-based boards
{ nixpkgs, socOverlays }:

let
  localSystem = "x86_64-linux";
  targetSystem = "aarch64-linux";

  # Native aarch64 packages
  pkgsNative = import nixpkgs {
    system = targetSystem;
    overlays = [ socOverlays.default ];
  };

  # Cross-compiled packages
  pkgsCross = import nixpkgs {
    inherit localSystem;
    crossSystem = targetSystem;
    overlays = [ socOverlays.default ];
  };

  # Import unfree predicate from lib
  unfree = import ../../lib/unfree.nix { lib = nixpkgs.lib; };
  allowUnfreePredicate = unfree.allowCixSky1Unfree;
in
rec {
  # Native aarch64 configuration
  native = nixpkgs.lib.nixosSystem {
    system = targetSystem;
    specialArgs = {
      cixSky1 = {
        inherit nixpkgs;
        pkgsKernel = pkgsNative;
      };
    };
    modules = [
      ../configuration.nix
      ./module.nix
      {
        nixpkgs.overlays = [ socOverlays.default ];
        nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
        networking.hostName = "sky1";
        # Minimal system for building SoC packages
        boot.loader.grub.enable = nixpkgs.lib.mkForce false;
        fileSystems."/" = nixpkgs.lib.mkForce { device = "none"; fsType = "tmpfs"; };
        fileSystems."/boot" = nixpkgs.lib.mkForce { device = "none"; fsType = "tmpfs"; };
      }
    ];
  };

  # Cross-compiled configuration
  cross = nixpkgs.lib.nixosSystem {
    system = localSystem;
    specialArgs = {
      cixSky1 = {
        inherit nixpkgs;
        pkgsKernel = pkgsCross;
      };
    };
    modules = [
      ../configuration.nix
      ./module.nix
      {
        nixpkgs.overlays = [ socOverlays.default ];
        nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
        networking.hostName = "sky1";
        nixpkgs.buildPlatform = localSystem;
        nixpkgs.hostPlatform = targetSystem;
        # Minimal system for building SoC packages
        boot.loader.grub.enable = nixpkgs.lib.mkForce false;
        fileSystems."/" = nixpkgs.lib.mkForce { device = "none"; fsType = "tmpfs"; };
        fileSystems."/boot" = nixpkgs.lib.mkForce { device = "none"; fsType = "tmpfs"; };
      }
    ];
  };
}
