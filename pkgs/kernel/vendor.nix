# Vendor kernel for CIX CD8180/CD8160 SoC (Sky1)
#
# Includes proprietary drivers for GPU, NPU (28.8 TOPS), ISP, VPU, and GPIO.
# Source: orangepi-xunlong/linux-orangepi

{ lib
, fetchFromGitHub
, linuxManualConfig
, ubootTools
, buildPackages
, ccacheWrapper
, ccache
, overrideCC
, ...
}:

let
  modDirVersion = "6.6.89";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "linux-orangepi";
    rev = "0cc923dcd40c973e72f3bc2dfbe274076afa4f6d"; # orange-pi-6.6-cix branch
    hash = "sha256-d3+setUX3CgQUvqVNdUgc2uDrU3CcQXKWyhcIBzlec0=";
  };

  # Use ccacheWrapper following the official nixpkgs pattern
  # Using /tmp/ccache for both local and CI builds
  # Local: can bind-mount /persist/cache/ccache to /tmp/ccache for persistence
  # GitHub Actions: uses actions/cache to persist between runs
  # Set to 10GB to maximize GitHub Actions cache limit
  ccacheConfig = ''
    export CCACHE_DIR=/tmp/ccache
    export CCACHE_COMPRESS=1
    export CCACHE_MAXSIZE=10G
  '';

in
(linuxManualConfig {
  inherit modDirVersion src;
  version = "${modDirVersion}-sky1";

  # Use ccache-wrapped stdenv (stdenv already handles cross-compilation correctly)
  # Note: We don't override stdenv here to preserve cross-compilation support.
  # ccache is applied via CC override in overrideAttrs instead.

  extraMeta = {
    description = "Vendor kernel for CIX CD8180/CD8160 SoC (Sky1) from orangepi-xunlong";
    maintainers = [ ];
    # Target platform is aarch64-linux, but allow building from x86_64-linux (cross-compilation)
    platforms = lib.platforms.linux;
    # Broken on platforms other than x86_64 and aarch64
    badPlatforms = lib.filter (p: !(lib.hasInfix "x86_64" p || lib.hasInfix "aarch64" p)) lib.platforms.linux;
  };

  # Use the vendor defconfig which includes all necessary options
  configfile = ./sky1_vendor_config;

  kernelPatches = [
    {
      name = "fwnode-regulator-fix-type-error";
      patch = ./patches/fwnode-regulator-fix-type-error.patch;
    }
    {
      name = "rtl-wifi-fix-makefile-includes";
      patch = ./patches/rtl-wifi-fix-makefile-includes.patch;
    }
    {
      name = "rtl-wifi-fix-halrf-includes";
      patch = ./patches/rtl-wifi-fix-halrf-includes.patch;
    }
    {
      name = "rtl-wifi-fix-aes-include-path";
      patch = ./patches/rtl-wifi-fix-aes-include-path.patch;
    }
    {
      name = "rtl8192eu-fix-makefile-includes";
      patch = ./patches/rtl8192eu-fix-makefile-includes.patch;
    }
    {
      name = "rtl8812au-fix-makefile-includes";
      patch = ./patches/rtl8812au-fix-makefile-includes.patch;
    }
    {
      name = "rtl8723ds-fix-makefile-includes";
      patch = ./patches/rtl8723ds-fix-makefile-includes.patch;
    }
    {
      name = "isp-driver-install-mntn-header";
      patch = ./patches/isp-driver-install-mntn-header.patch;
    }
  ];

  allowImportFromDerivation = true;

}).overrideAttrs (old: {
  name = "k";

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ ubootTools ccache ];

  makeFlags = (old.makeFlags or [ ]) ++ [ "ARCH=arm64" ];

  preBuild = (old.preBuild or "") + ''
    echo "ccache: Starting build with persistent cache"
    ${ccacheConfig}
    ccache --zero-stats
    
    # Wrap CC with ccache if not already wrapped
    if [[ "$CC" != *ccache* ]]; then
      export CC="ccache $CC"
    fi
  '';

  postBuild = old.postBuild or "" + ''
    echo "ccache statistics for this build:"
    ccache --show-stats
  '';

  postInstall = (old.postInstall or "") + ''
    # Install device tree blobs for CIX Sky1 SoC
    echo "Installing device tree blobs..."
    mkdir -p $out/dtbs/cix
    
    if [ -d arch/arm64/boot/dts/cix ]; then
      cp arch/arm64/boot/dts/cix/*.dtb $out/dtbs/cix/
      echo "Installed DTBs:"
      ls -lh $out/dtbs/cix/*.dtb
    else
      echo "Warning: No CIX device tree blobs found in arch/arm64/boot/dts/cix"
    fi
  '';
})
