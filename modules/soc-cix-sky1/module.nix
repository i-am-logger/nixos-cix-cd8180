# Base configuration for CIX Sky1 SoC (CD8180/CD8160)
# Common settings shared across all Sky1-based boards
# Hardware: 12-core CPU, Mali-G610 MP4 GPU, 28.8 TOPS NPU, ISP, VPU
{ config, pkgs, lib, ... }:

{
  # Boot configuration for CIX Sky1 SoC
  boot = {
    # CIX Sky1 vendor kernel with all drivers
    kernelPackages = pkgs.cixSky1VendorKernelPackages;

    # CIX opensource kernel modules (GPU, NPU, ISP, VPU)
    # These are SoC-specific, not board-specific
    extraModulePackages = with (pkgs.callPackage ../../pkgs/kernel-modules { kernel = config.boot.kernelPackages.kernel; }); [
      mali-gpu # Mali-G610 MP4 GPU kernel driver
      aipu-npu # 28.8 TOPS NPU kernel driver
      armcb-isp # ARM Camera Block ISP kernel driver
      mvx-vpu # MVX Video Processing Unit kernel driver
    ];

    # Common kernel parameters for Sky1 SoC
    kernelParams = [
      "rootwait"
      "earlycon" # enable early console via serial/HDMI
      "consoleblank=0" # disable screen saver
    ];

    # Minimal initrd configuration
    initrd = {
      includeDefaultModules = lib.mkForce false;

      availableKernelModules = lib.mkForce [
        # Storage
        "mmc_block" # SD card
        "nvme" # NVMe SSD
        "ahci" # SATA
        "sd_mod" # SD card

        # USB
        "xhci_pci"
        "usbhid"
        "usb_storage"

        # Network (critical for PXE)
        "r8169" # RTL8126 ethernet

        # Device mapper (for LVM, etc.)
        "dm_mod"

        # Input devices
        "hid"
        "hid_generic"
        "usbhid"

        # Graphics (for early framebuffer console)
        "panfrost" # Mali GPU DRM driver (for HDMI/DP framebuffer)
        "drm"
        "drm_kms_helper"
        "drm_display_helper"
      ];
    };

    kernelModules = [ ];
  };

  # Hardware firmware required by Sky1 SoC
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [
      pkgs.cix-firmware
      pkgs.cix-vpu-firmware
    ];

    # Mali-G610 MP4 GPU drivers (OpenGL ES, Vulkan)
    # Note: GPU drivers are in systemPackages but hardware.graphics.package
    # integration is untested and may require restructuring the package
    # graphics = {
    #   package = lib.mkDefault pkgs.cix-gpu-umd;
    # };
  };

  # CIX Sky1 proprietary userspace drivers and tools
  # These work with the kernel modules above
  environment.systemPackages = with pkgs; [
    # GPU/NPU/ISP userspace drivers
    cix-gpu-umd # Mali-G610 MP4 GPU userspace drivers (OpenGL ES, Vulkan)
    cix-npu-umd # 28.8 TOPS NPU userspace drivers
    cix-isp-umd # Image Signal Processor userspace drivers

    # Graphics libraries (essential for GPU to work)
    cix-libdrm # DRM library for display/GPU integration
    cix-mesa # Mesa 3D graphics library with Mali support
    cix-libglvnd # OpenGL vendor neutral dispatch

    # Multimedia (hardware accelerated)
    cix-gstreamer # GStreamer with GPU/VPU acceleration

    # Vendor tools
    cix-tools # I3C transfer tool and power management (i3ctransfer, pmtool)
  ];

  # Set platform
  nixpkgs.hostPlatform = "aarch64-linux";

  # Default filesystem configuration
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  # Enable DHCP by default
  networking.useDHCP = lib.mkDefault true;
}
