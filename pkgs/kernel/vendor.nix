# Vendor kernel for CIX CD8180/CD8160 SoC (Sky1)
#
# Includes proprietary drivers for GPU, NPU (28.8 TOPS), ISP, VPU, and GPIO.
# Source: orangepi-xunlong/linux-orangepi

{ lib
, fetchFromGitHub
, linuxManualConfig
, ubootTools
, ...
}:

let
  modDirVersion = "6.1.44";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "linux-orangepi";
    rev = "0cc923dcd40c973e72f3bc2dfbe274076afa4f6d";
    hash = "sha256-d3+setUX3CgQUvqVNdUgc2uDrU3CcQXKWyhcIBzlec0=";
  };

in
(linuxManualConfig {
  inherit modDirVersion src;
  version = "${modDirVersion}-sky1";

  extraMeta = {
    description = "Vendor kernel for CIX CD8180/CD8160 SoC (Sky1) from orangepi-xunlong";
    maintainers = [ ];
    platforms = [ "aarch64-linux" ];
  };

  # Use the vendor defconfig which includes all necessary options
  configfile = ./sky1_vendor_config;

  # Additional config overrides if needed
  # Note: linuxManualConfig doesn't support 'config' attribute
  # All options must be in the configfile

  kernelPatches = [ ];

  allowImportFromDerivation = true;

}).overrideAttrs (old: {
  name = "k";

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ ubootTools ];

  makeFlags = (old.makeFlags or [ ]) ++ [ "ARCH=arm64" ];

  postInstall = (old.postInstall or "") + ''
    mkdir -p $out/dtbs
    cp arch/arm64/boot/dts/cix/*.dtb $out/dtbs/ 2>/dev/null || true
  '';
})
