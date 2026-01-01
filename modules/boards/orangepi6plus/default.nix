# Orange Pi 6 Plus board - entry point
# Returns: { module, configurations, packages, mkPackages }
{ nixpkgs ? null, socOverlays ? null, pkgs ? null, pkgsNativeUnfree ? null, pkgsCrossUnfree ? null }:

let
  boardConfig =
    if nixpkgs != null && socOverlays != null then
      import ./configurations.nix { inherit nixpkgs socOverlays pkgs pkgsNativeUnfree pkgsCrossUnfree; }
    else
      { module = null; configurations = { }; packages = { }; };
in
{
  module = boardConfig.module;
  configurations = boardConfig.configurations;
  packages = boardConfig.packages or { };

  # Function to regenerate packages with different pkgs
  mkPackages = { pkgs, pkgsNativeUnfree, pkgsCrossUnfree }:
    (import ./configurations.nix {
      inherit nixpkgs socOverlays pkgs pkgsNativeUnfree pkgsCrossUnfree;
    }).packages;
}
