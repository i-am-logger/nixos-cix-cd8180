# CIX CD8180/CD8160 SoC overlays
# Kernels, drivers, firmware, and tools
let
  kernels = final: prev: (import ../../pkgs/kernel { pkgs = prev; });

  drivers = final: prev: {
    cix-gpu-umd = final.callPackage ../../pkgs/drivers/gpu { };
    cix-npu-umd = final.callPackage ../../pkgs/drivers/npu { };
    cix-isp-umd = final.callPackage ../../pkgs/drivers/isp { };
    cix-vpu-firmware = (final.callPackage ../../pkgs/drivers/vpu { }).vpu-firmware;
    cix-firmware = final.callPackage ../../pkgs/firmware { };
    cix-tools = final.callPackage ../../pkgs/cix-tools { };
  };
in
{
  inherit kernels drivers;

  default = final: prev:
    kernels final prev //
    drivers final prev;
}
