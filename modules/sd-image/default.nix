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

    # Populate ESP with GRUB, kernel, initrd, and device tree blobs
    populateFirmwareCommands =
      let
        kernel = config.boot.kernelPackages.kernel;
        grubEfi = pkgs.cix-grub-efi;
        initrd = "${config.system.build.initialRamdisk}/initrd";

        # Generate GRUB config
        kernelParams = lib.concatStringsSep " " (config.boot.kernelParams ++ [
          "root=LABEL=${config.sdImage.rootVolumeLabel}"
          "init=${config.system.build.toplevel}/init"
        ]);

        grubCfg = pkgs.writeText "grub.cfg" ''
          set debug=loader,mm
          set term=vt100
          set default=0
          set timeout=2
        
          menuentry 'NixOS - Orange Pi 6 Plus (ACPI)' {
              linux /Image ${kernelParams}
              initrd /initrd
          }
        
          menuentry 'NixOS - Orange Pi 6 Plus (Device Tree)' {
              devicetree /dtbs/cix/sky1-orangepi-6-plus.dtb
              linux /Image ${lib.replaceStrings ["acpi=force"] ["acpi=off"] kernelParams}
              initrd /initrd
          }
        '';
      in
      ''
        echo "Populating ESP partition..."
      
        # Install vendor GRUB EFI bootloader
        echo "Installing GRUB EFI bootloader..."
        cp -r ${grubEfi}/EFI firmware/
      
        # Install GRUB configuration
        echo "Installing GRUB configuration..."
        mkdir -p firmware/grub
        cp ${grubCfg} firmware/grub/grub.cfg
      
        # Install kernel
        echo "Installing kernel..."
        cp ${kernel}/Image firmware/
      
        # Install initrd
        echo "Installing initrd..."
        cp ${initrd} firmware/initrd
      
        # Install device tree blobs
        echo "Installing device tree blobs..."
        mkdir -p firmware/dtbs/cix
        if [ -d ${kernel}/dtbs/cix ]; then
          cp ${kernel}/dtbs/cix/*.dtb firmware/dtbs/cix/
          echo "Installed device tree blobs:"
          ls -lh firmware/dtbs/cix/
        else
          echo "Warning: No CIX device tree blobs found at ${kernel}/dtbs/cix"
        fi
      
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
