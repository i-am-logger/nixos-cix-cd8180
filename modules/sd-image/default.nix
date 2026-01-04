# SD card image generation settings for CIX Sky1 SoC boards
#
# This module configures GPT partition layout with UEFI boot support.
# - ESP partition at 10 MiB offset (vendor bootloader requirement)
# - GRUB EFI bootloader with ACPI and Device Tree support
# - Auto-resize root partition on first boot

{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  # Standardized image naming: nixos-{board}-sd-image
  image.baseName = "nixos-${config.networking.hostName}-sd-image";

  sdImage = {
    # Enable compression (zstd)
    compressImage = true;

    # Partition layout matching vendor requirements
    firmwarePartitionOffset = 10; # MiB - 10 MiB reserved for bootloader/firmware
    firmwareSize = 200; # MiB - ESP partition size (matches vendor)
    firmwarePartitionName = "ESP"; # EFI System Partition label

    # Root partition configuration
    rootPartitionUUID = null; # Auto-generate UUID
    rootVolumeLabel = "NIXOS_SD"; # NixOS standard label

    # Populate ESP with GRUB EFI bootloader and boot files
    # Use the bootloader module to ensure consistency between SD image and nixos-rebuild
    populateFirmwareCommands =
      let
        grubEfi = pkgs.cix-grub-efi;
        toplevel = config.system.build.toplevel;
        bootloader = config.system.build.installBootLoader;
      in
      ''
        echo "Populating ESP partition..."
      
        # Install vendor GRUB EFI bootloader
        echo "Installing GRUB EFI bootloader..."
        cp -r ${grubEfi}/EFI firmware/
      
        # Use the bootloader module to install kernel, initrd, dtbs, and grub.cfg
        # This ensures the SD image uses the same multi-generation logic as nixos-rebuild
        echo "Installing bootloader configuration..."
        ${bootloader} ${toplevel} firmware
      
        echo "ESP partition populated successfully"
      '';

    # NixOS handles boot files automatically via boot.loader.grub
    populateRootCommands = "";

    # Post-build information
    postBuildCommands = ''
      echo ""
      echo "======================================"
      echo "NixOS SD Image Built Successfully"
      echo "======================================"
      echo "Flash to SD card with:"
      echo "  zstd -d nixos-*.img.zst"
      echo "  sudo dd if=nixos-*.img of=/dev/sdX bs=4M status=progress conv=fsync"
      echo ""
      echo "Boot configuration:"
      echo "  - Bootloader: GRUB EFI (UEFI)"
      echo "  - Default: ACPI mode"
      echo "  - Alternative: Device Tree mode"
      echo "  - Serial console: ttyAMA2,115200"
      echo "======================================"
    '';
  };

  # File system configuration
  # ESP partition mounted at /boot for GRUB access
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = [ "nofail" "noauto" ];
    };
  };
}
