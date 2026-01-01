{
  description = "NixOS configuration for CIX CD8180/CD8160 SoC boards";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    let
      # Target architecture (what we're building FOR)
      targetSystem = "aarch64-linux";

      # CIX Sky1 SoC (overlays, module, configurations)
      cixSky1 = import ./modules/soc-cix-sky1 { inherit nixpkgs; };

      # Helper functions
      lib = import ./lib {
        inherit nixpkgs targetSystem;
        socOverlays = cixSky1.overlays;
      };

      # Orange Pi 6 Plus board
      orangepi6plus = import ./modules/boards/orangepi6plus {
        inherit nixpkgs;
        socOverlays = cixSky1.overlays;
      };
    in
    {
      overlays.default = cixSky1.overlays.default;

      nixosModules = {
        cix-sky1 = cixSky1.module;
        orangepi6plus = orangepi6plus.module;
      };

      nixosConfigurations = orangepi6plus.configurations;
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Native target packages (aarch64 native)
        pkgsNativeUnfree = import nixpkgs {
          system = targetSystem;
          overlays = [ cixSky1.overlays.default ];
          config.allowUnfree = true;
        };

        # Cross-compiled packages (for devShells)
        pkgsCrossUnfree = import nixpkgs {
          localSystem = system;
          crossSystem = targetSystem;
          overlays = [ cixSky1.overlays.default ];
          config.allowUnfree = true;
        };

        # SoC packages (kernel, drivers, firmware, tools) for THIS system
        socPackages = lib.mkSocPackages {
          soc = cixSky1.configurations;
          inherit pkgsNativeUnfree pkgsCrossUnfree;
        };

        # Board packages for THIS system
        orangepi6plusPackages = lib.mkBoardPackages {
          inherit pkgs pkgsNativeUnfree pkgsCrossUnfree;
          board = orangepi6plus;
        };
      in
      {
        packages = socPackages // orangepi6plusPackages;

        devShells = import ./devshells.nix { inherit pkgs pkgsCrossUnfree; };
      });
}
