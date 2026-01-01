# Development shells for NixOS CIX CD8180/CD8160
{ pkgs, pkgsCrossUnfree }:

{
  default = pkgs.mkShell {
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

  kernel = pkgs.mkShell {
    name = "kernel-build-env";
    packages = with pkgs; [
      pkg-config
      ncurses
      pkgsCrossUnfree.stdenv.cc
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
}
