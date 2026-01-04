# CIX CD8180/CD8160 SoC overlays
# Kernels, drivers, firmware, and tools
let
  kernels = final: prev: (import ../../pkgs/kernel { pkgs = prev; });

  # Shared sources and helpers
  cixComponent = final: prev: {
    # Shared sources for all component_cix-next packages
    cix-component-srcs = final.callPackage ../../pkgs/cix-component/srcs.nix { };

    # Helper for building .deb packages from component_cix-next
    mkCixDebPackage = final.callPackage ../../pkgs/cix-component/mkDebPackage.nix { };
  };

  drivers = final: prev: {
    # GPU/NPU/ISP/VPU userspace drivers
    cix-gpu-umd = final.callPackage ../../pkgs/drivers/gpu { };
    cix-npu-umd = final.callPackage ../../pkgs/drivers/npu { };
    cix-isp-umd = final.callPackage ../../pkgs/drivers/isp { };
    cix-vpu-firmware = (final.callPackage ../../pkgs/drivers/vpu { }).vpu-firmware;

    # Graphics libraries (for GPU)
    cix-libdrm = final.callPackage ../../pkgs/graphics/libdrm.nix { };
    cix-mesa = final.callPackage ../../pkgs/graphics/mesa.nix { };
    cix-libglvnd = final.callPackage ../../pkgs/graphics/libglvnd.nix { };

    # Multimedia
    cix-gstreamer = final.callPackage ../../pkgs/multimedia/gstreamer.nix { };
    cix-audio-dsp = final.callPackage ../../pkgs/multimedia/audio-dsp.nix { };
    cix-cpipe = final.callPackage ../../pkgs/multimedia/cpipe.nix { };

    # AI frameworks (NPU accelerated)
    cix-llama-cpp = final.callPackage ../../pkgs/ai/llama-cpp.nix { };
    cix-mnn = final.callPackage ../../pkgs/ai/mnn.nix { };

    # Testing tools
    cix-gpu-test = final.callPackage ../../pkgs/testing/gpu-test.nix { };
    cix-vpu-test = final.callPackage ../../pkgs/testing/vpu-test.nix { };

    # Firmware & tools
    cix-firmware = final.callPackage ../../pkgs/firmware { };
    cix-grub-efi = final.callPackage ../../pkgs/firmware/grub-efi.nix { };
    cix-optee = final.callPackage ../../pkgs/firmware/optee.nix { };
    cix-tools = final.callPackage ../../pkgs/cix-tools { };
  };
in
{
  inherit kernels drivers cixComponent;

  default = final: prev: cixComponent final prev // kernels final prev // drivers final prev;
}
