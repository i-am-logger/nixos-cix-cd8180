# CIX Sky1 SoC - entry point
# Returns: { overlays, module, configurations }
{ nixpkgs ? null, socOverlays ? null }:

let
  # Import overlays first (they're always available)
  overlays = import ./overlays.nix;

  # If nixpkgs is provided, also return module and configurations
  hasNixpkgs = nixpkgs != null;

  # Use provided overlays or default to local ones
  actualOverlays = if socOverlays != null then socOverlays else overlays;
in
{
  inherit overlays;

  module = import ./module.nix;

  configurations =
    if hasNixpkgs then
      import ./configurations.nix { inherit nixpkgs; socOverlays = actualOverlays; }
    else
      null;
}
