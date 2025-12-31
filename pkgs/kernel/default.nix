{ pkgs }:

let
  # Import individual kernel packages
  vendorKernel = pkgs.callPackage ./vendor.nix { };
  mainlineKernel = pkgs.callPackage ./mainline.nix { };
in
{
  # Vendor kernel packages from orangepi-xunlong
  cixSky1VendorKernelPackages = pkgs.linuxPackagesFor vendorKernel;

  # Mainline kernel packages with basic CIX CD8180/CD8160 support
  cixSky1MainlineKernelPackages = pkgs.linuxPackagesFor mainlineKernel;

  # Export individual kernels for direct use
  cixSky1VendorKernel = vendorKernel;
  cixSky1MainlineKernel = mainlineKernel;
}
