# Mainline kernel for CIX CD8180/CD8160 SoC (Sky1)
#
# NOTE: Mainline kernel support for CIX CD8180/CD8160 (Sky1) is INCOMPLETE as of Linux 6.11
# - Only Radxa Orion O6 device tree is included
# - Orange Pi 6 Plus device tree is NOT in mainline
# - No proprietary GPU/NPU/ISP/VPU driver support
#
# This package is provided for future use when mainline support improves.
# For production use, MUST use vendor kernel (vendor.nix).

{ lib
, buildLinux
, fetchurl
, ...
} @ args:

buildLinux (args // {
  version = "6.11.0";
  modDirVersion = "6.11.0";

  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.tar.xz";
    sha256 = "sha256-n7fXlQ1eB+GM4aP3Ydj2bAr/sxZ3yv+jC8W6W2O3PxQ=";
  };

  kernelPatches = [ ];

  extraMeta = {
    description = "Mainline kernel with basic CIX CD8180/CD8160 SoC (Sky1) support";
    maintainers = [ ];
    platforms = [ "aarch64-linux" ];
  };

  structuredExtraConfig = with lib.kernel; {
    ARCH_CIX = yes;

    EFI = yes;
    EFI_STUB = yes;

    PCI = yes;
    PCIE_CADENCE = yes;
    NVME_CORE = yes;

    PINCTRL_SKY1 = yes;
    CIX_MAILBOX = yes;
    SPI_CADENCE = yes;
  };
} // (args.argsOverride or { }))
