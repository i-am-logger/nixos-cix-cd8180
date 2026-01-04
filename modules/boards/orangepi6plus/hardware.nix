# Orange Pi 6 Plus board-specific hardware configuration
# Board uses CIX Sky1 SoC (CD8180/CD8160) - see soc-cix-sky1/module.nix for SoC config
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../soc-cix-sky1/module.nix # CIX Sky1 SoC base configuration
  ];

  config = {
    # Orange Pi specific packages
    nixpkgs.overlays = [
      (final: prev: {
        orangepi-config = final.callPackage ../../../pkgs/orangepi-config { };
        wiringop = final.callPackage ../../../pkgs/wiringop { };
      })
    ];

    boot = {
      # UEFI boot with vendor GRUB (no NixOS GRUB due to cross-compilation complexity)
      # GRUB EFI binary and config are installed manually in SD image module
      # Use mkDefault to allow netboot and other specialized configs to override
      loader = {
        grub.enable = lib.mkDefault false; # Disable NixOS GRUB (use vendor binary instead)
        timeout = lib.mkDefault 2;

        efi = {
          canTouchEfiVariables = false; # No EFI NVRAM on embedded systems
          efiSysMountPoint = "/boot"; # ESP mounted at /boot
        };
      };

      # CIX Sky1 SoC kernel parameters
      # Default boot uses ACPI mode (vendor default for production)
      kernelParams = [
        # Console configuration (last console= entry becomes primary /dev/console)
        "console=ttyAMA2,115200" # PL011 UART serial console (vendor uses ttyAMA2)
        "console=tty0" # HDMI/framebuffer console (primary output, listed last)

        # EFI and early boot
        "efi=noruntime" # Disable EFI runtime services (required for CIX)
        "earlycon=pl011,0x040d0000" # Early console for debugging

        # Hardware configuration
        "arm-smmu-v3.disable_bypass=0" # IOMMU settings
        "cma=640M" # Contiguous Memory Allocator (required for GPU/VPU)

        # Graphics - disable EFI framebuffer, force fbcon to initialize on all framebuffers
        "video=efifb:off" # Disable EFI simple framebuffer (let DRM driver be fb0)
        "fbcon=nodefer" # Force fbcon to bind immediately when framebuffer appears

        # Boot mode and logging
        "acpi=force" # Use ACPI mode (vendor default, better hardware support)
        "loglevel=7" # Debug level for graphics/boot troubleshooting (reduce to 4 once stable)
        "pcie_aspm=off" # Disable PCIe ASPM (NVMe stability)
      ];
    };

    # Serial console service (PL011 UART on ttyAMA2)
    systemd.services."serial-getty@ttyAMA2" = {
      enable = true;
      wantedBy = [ "getty.target" ];
    };

    # Orange Pi board-specific tools (GPIO, hardware config)
    environment.systemPackages = with pkgs; [
      orangepi-config # Orange Pi hardware configuration tool
      wiringop # Orange Pi GPIO library and tools
    ];
  };
}
