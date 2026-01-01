# Unfree package predicates for CIX Sky1 SoC
# This allows proprietary drivers and firmware to be installed
{ lib }:

{
  # Predicate for allowing CIX Sky1 proprietary packages
  # Used in nixosModules and configurations
  allowCixSky1Unfree = pkg: builtins.elem (lib.getName pkg) [
    "cix-gpu-umd" # Mali-G610 MP4 GPU userspace drivers
    "cix-npu-umd" # 28.8 TOPS NPU userspace drivers
    "cix-isp-umd" # Image Signal Processor userspace drivers
    "cix-vpu-firmware" # Video Processing Unit firmware
    "cix-firmware" # General SoC firmware
    "cix-tools" # SoC tools (i3ctransfer, pmtool)
  ];
}
