# Network boot configuration for Orange Pi 6 Plus via UEFI PXE
#
# Uses UEFI PXE boot (no U-Boot required).
# Enables network boot without SD card.
#
# Board-specific: RTL8126 ethernet driver configuration for PXE boot.
# Use with: nixosModules.boards.orangepi6plus + nixosModules.orangepi6plus.netboot

{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  boot.supportedFilesystems = lib.mkForce [ "vfat" "ext4" "btrfs" ];

  # Critical: Ethernet driver must be in initrd for PXE boot to work
  # The vendor kernel's RTL8126 driver needs to be available immediately
  boot.initrd = {
    availableKernelModules = [
      "r8169" # Realtek ethernet
      "r8125" # RTL8125 variant
      "r8126" # RTL8126 variant
      "nvme"
      "xhci_pci"
      "usbhid"
    ];

    # Force ethernet into initrd (not as late-loaded module)
    kernelModules = [ "r8169" ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = "aarch64-linux";
}
