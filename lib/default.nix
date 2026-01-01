# Helper functions for flake
{ nixpkgs, socOverlays, targetSystem }:

let
  unfree = import ./unfree.nix { lib = nixpkgs.lib; };
in
{
  # Re-export unfree utilities
  inherit (unfree) allowCixSky1Unfree;

  # Generate packages for a board (using board's mkPackages function)
  # args: { pkgs, pkgsNativeUnfree, pkgsCrossUnfree, board }
  # pkgs: Base packages for current system (used for runCommand, symlinkJoin, etc.)
  # pkgsNativeUnfree: Native target packages with unfree allowed
  # pkgsCrossUnfree: Cross-compiled packages with unfree allowed
  # board: Board configuration (must have mkPackages function)
  # Returns: { packages }
  mkBoardPackages = { pkgs, pkgsNativeUnfree, pkgsCrossUnfree, board }:
    board.mkPackages { inherit pkgs pkgsNativeUnfree pkgsCrossUnfree; };

  # Generate SoC packages (kernel, drivers, firmware, tools) for a specific system
  # args: { soc, pkgsNativeUnfree, pkgsCrossUnfree }
  # soc: SoC configuration from configurations.nix (has .native and .cross)
  # pkgsNativeUnfree: Native target packages with unfree allowed
  # pkgsCrossUnfree: Cross-compiled packages with unfree allowed
  # Returns: { kernel, kernel-cross, drivers, drivers-cross, firmware, firmware-cross, tools, tools-cross }
  mkSocPackages = { soc, pkgsNativeUnfree, pkgsCrossUnfree }:
    {
      # Kernel and drivers (from SoC configurations)
      kernel = soc.native.config.boot.kernelPackages.kernel;
      kernel-cross = soc.cross.config.boot.kernelPackages.kernel;

      drivers = soc.native.config.system.build.modulesClosure;
      drivers-cross = soc.cross.config.system.build.modulesClosure;

      # Firmware and tools (from overlays)
      firmware = pkgsNativeUnfree.cix-firmware;
      firmware-cross = pkgsCrossUnfree.cix-firmware;

      tools = pkgsNativeUnfree.cix-tools;
      tools-cross = pkgsCrossUnfree.cix-tools;
    };
}
