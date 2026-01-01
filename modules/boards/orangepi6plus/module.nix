# Orange Pi 6 Plus NixOS module
# Includes board configuration + SoC overlays + unfree predicate
socOverlays:

{ config, pkgs, lib, ... }:
let
  unfree = import ../../../lib/unfree.nix { inherit lib; };
in
{
  imports = [ ./hardware.nix ];

  nixpkgs.overlays = [ socOverlays.default ];

  nixpkgs.config.allowUnfreePredicate = unfree.allowCixSky1Unfree;
}
