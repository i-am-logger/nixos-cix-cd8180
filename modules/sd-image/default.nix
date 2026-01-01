# SD card image generation settings for CIX Sky1 SoC boards
#
# This module configures partition layout and image compression.
# Hardware configuration comes from the board module (imported by flake).

{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  # Standardized image naming: nixos-{board}-sd-image-{version}-{arch}
  # This overrides the default nixos-image-sd-card-* naming
  image.baseName = "nixos-${config.networking.hostName}-sd-image-${config.system.nixos.version}-${pkgs.stdenv.hostPlatform.system}";

  sdImage = {
    compressImage = true;

    firmwareSize = 512;
    firmwarePartitionName = "BOOT";

    rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";

    populateRootCommands = "";

    # UEFI bootloader will be added when firmware package is implemented
    populateFirmwareCommands = ''
      mkdir -p firmware/EFI/BOOT
      echo "UEFI bootloader (BOOTAA64.efi) required from vendor firmware" > firmware/EFI/BOOT/README.txt
    '';

    postBuildCommands = ''
      echo "Image built. Flash with: dd if=\$img of=/dev/sdX bs=4M status=progress"
    '';
  };
}
