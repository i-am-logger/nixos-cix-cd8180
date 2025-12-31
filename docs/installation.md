# Installation Guide

This guide covers all installation methods for NixOS on CIX CD8180/CD8160 (Sky1) based boards.

## Prerequisites

- NixOS or Linux system with Nix installed
- For cross-compilation: x86_64 system
- For native builds: aarch64 system

## Installation Methods

### Option 1: SD Card Boot

Build an image, flash to SD card, and boot.

#### 1. Build SD Card Image

**Cross-compile from x86_64** (recommended):
```bash
nix build .#sdImage-cross
```

**Native build on aarch64**:
```bash
nix build .#sdImage
```

The image will be in `result/sd-image/nixos-image-*.img.zst`

#### 2. Flash to SD Card

```bash
# Decompress and flash
zstd -d result/sd-image/*.img.zst
sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your SD card device (check with `lsblk`).

#### 3. Boot

1. Insert SD card into the board
2. Power on the board
3. The board should boot via UEFI

**Note**: Board requires UEFI firmware (pre-installed on Orange Pi 6 Plus).

---

### Option 2: Boot from NVMe SSD

Install to NVMe SSD after initial SD card setup.

#### 1. Boot from SD Card

First, boot the board from SD card with your NixOS configuration.

#### 2. Partition and Format NVMe SSD

```bash
# List available drives
lsblk

# Partition the NVMe SSD (e.g., /dev/nvme0n1)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 512MiB 100%

# Format partitions
sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkfs.ext4 -L NIXOS_SSD /dev/nvme0n1p2
```

#### 3. Mount and Install

```bash
# Mount the new partitions
sudo mount /dev/disk/by-label/NIXOS_SSD /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot

# Install NixOS to SSD
sudo nixos-install --root /mnt --no-root-passwd
```

#### 4. Update Configuration

Update your configuration to use the SSD labels:

```nix
fileSystems."/" = {
  device = "/dev/disk/by-label/NIXOS_SSD";
  fsType = "ext4";
};

fileSystems."/boot" = {
  device = "/dev/disk/by-label/BOOT";
  fsType = "vfat";
};
```

#### 5. Reboot

```bash
sudo reboot
```

Remove the SD card and reboot. The UEFI firmware will automatically boot from the NVMe SSD.

---

### Option 3: Network Boot (PXE)

Boot over the network without local storage.

#### 1. Build Netboot Components

```bash
# Build all netboot components in one package
nix build .#netboot
```

This creates a single package with:
- `result/kernel` - Linux kernel
- `result/initrd` - Initial ramdisk
- `result/netboot.ipxe` - iPXE boot script

#### 2. Setup TFTP/HTTP Server

Copy the files to your PXE server:

```bash
# Example TFTP layout
cp result/kernel /srv/tftp/nixos-cix-cd8180/kernel
cp result/initrd /srv/tftp/nixos-cix-cd8180/initrd
cp result/netboot.ipxe /srv/tftp/nixos-cix-cd8180/boot.ipxe
```

#### 3. Configure iPXE

Add to your iPXE menu or chainload directly:

```
#!ipxe
chain http://your-server/nixos-cix-cd8180/boot.ipxe
```

Or serve via TFTP:

```
#!ipxe
chain tftp://your-server/nixos-cix-cd8180/boot.ipxe
```

#### 4. Boot from Network

1. Power on the board
2. Enter UEFI boot menu (usually ESC or F12)
3. Select "Network Boot" or "PXE Boot"
4. Board will download kernel and initrd from your server

#### Network Boot Features

- Deploy to multiple boards
- No SD card or local storage required
- Update by replacing files on server
- Suitable for testing and development

#### Example PXE Server Setup

Using `dnsmasq` for DHCP + TFTP:

```bash
# /etc/dnsmasq.conf
enable-tftp
tftp-root=/srv/tftp
dhcp-boot=ipxe.efi

# Serve iPXE boot script
dhcp-match=set:efi-arm64,option:client-arch,11
dhcp-boot=tag:efi-arm64,nixos-cix-cd8180/boot.ipxe
```

---

## Post-Installation

See [examples/](../examples/) for configuration examples.

## Troubleshooting

### Board won't boot from SD card

1. Verify UEFI firmware is installed (pre-installed on Orange Pi 6 Plus)
2. Check SD card is properly flashed: `sudo fdisk -l /dev/sdX`
3. Try a different SD card

### Can't find NVMe drive

1. Check M.2 slot is properly seated
2. Verify NVMe support in UEFI settings
3. Check `dmesg | grep nvme` for kernel messages

### Network boot fails

1. Verify DHCP server is responding
2. Check TFTP/HTTP server is accessible
3. Review UEFI network settings
4. Check firewall rules on PXE server
