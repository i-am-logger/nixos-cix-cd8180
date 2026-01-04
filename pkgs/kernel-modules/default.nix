# CIX CD8180/CD8160 (Sky1) SoC kernel modules
# Opensource kernel drivers from component_cix-next

{ callPackage, kernel }:

{
  # GPU kernel driver - Mali-G610 MP4
  # Use Mali GPU driver from DKMS package (official vendor source with Sky1 modifications)
  # Falls back to prebuilt if compilation fails
  mali-gpu = callPackage ./mali-gpu-from-dkms.nix { inherit kernel; };

  # NPU kernel driver - ARM China Zhouyi AIPU (28.8 TOPS)
  aipu-npu = callPackage ./aipu-npu.nix { inherit kernel; };

  # ISP kernel driver - ARM Camera Block
  armcb-isp = callPackage ./armcb-isp.nix { inherit kernel; };

  # VPU kernel driver - MVX Video Processing Unit
  mvx-vpu = callPackage ./mvx-vpu.nix { inherit kernel; };
}
