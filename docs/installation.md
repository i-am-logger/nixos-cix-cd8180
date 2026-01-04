# Installation Guide

This guide covers all installation methods for NixOS on CIX CD8180/CD8160 (Sky1) based boards.

## Prerequisites

- Linux system with `zstd` and `dd` utilities
- SD card (16GB or larger recommended)
- For network boot: TFTP/HTTP server

## Installation Methods

### Option 1: SD Card Boot

Download a pre-built image, flash to SD card, and boot.

#### 1. Download SD Card Image

Go to the [latest release](https://github.com/i-am-logger/nixos-cix-cd8180/releases/latest) and download the SD card image:

```bash
# Download the latest SD image
wget https://github.com/i-am-logger/nixos-cix-cd8180/releases/latest/download/nixos-orangepi6plus-sd-image-<VERSION>-aarch64-linux.img.zst
```

Replace `<VERSION>` with the actual version from the release page (e.g., `2026.01.01-9d6dbab`).

#### 2. Flash to SD Card

```bash
# Decompress and flash
zstd -d nixos-orangepi6plus-sd-image-*.img.zst
sudo dd if=nixos-orangepi6plus-sd-image-*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your SD card device (check with `lsblk`).

⚠️ **Warning**: Double-check the device name - `dd` will overwrite the entire device!

#### 3. Boot

1. Insert SD card into the board
2. Connect serial console to ttyAMA2 (optional, for debugging)
3. Power on the board
4. GRUB menu will appear with two boot options:
   - **NixOS - Orange Pi 6 Plus (ACPI)** - Default, production mode
   - **NixOS - Orange Pi 6 Plus (Device Tree)** - Alternative mode

The system will boot automatically after 2 seconds.

**Boot Process:**
- UEFI firmware loads GRUB EFI bootloader
- GRUB loads kernel, initramfs, and optionally device tree
- NixOS boots with configured parameters

**Serial Console:**
- Port: ttyAMA2
- Baud rate: 115200
- No parity, 8 data bits, 1 stop bit

**Default credentials:**
- Username: `nixos`
- Password: `nixos`
- SSH: Enabled (port 22)

⚠️ **Change the password immediately after first boot:**
```bash
passwd              # Change user password
sudo passwd root    # Change root password
```

**Note**: Board requires UEFI firmware (pre-installed on Orange Pi 6 Plus).

#### Building from Source

If you want to build the image yourself instead of using pre-built releases, see [Development Guide](development.md#building-images).

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

#### 1. Download Netboot Package

Go to the [latest release](https://github.com/i-am-logger/nixos-cix-cd8180/releases/latest) and download the netboot archive:

```bash
# Download the latest netboot package
wget https://github.com/i-am-logger/nixos-cix-cd8180/releases/latest/download/nixos-orangepi6plus-netboot-<VERSION>-aarch64-linux.tar.gz
```

Replace `<VERSION>` with the actual version from the release page (e.g., `2026.01.01-9d6dbab`).

#### 2. Extract and Setup TFTP/HTTP Server

The tarball contains files at the root level (no subdirectory). Extract directly to your PXE server directory:

```bash
# Create directory for netboot files
sudo mkdir -p /srv/tftp/nixos-cix-cd8180

# Extract archive directly to TFTP directory
# The tarball contains files at root level, so they extract directly to the target directory
sudo tar -xzf nixos-orangepi6plus-netboot-*.tar.gz -C /srv/tftp/nixos-cix-cd8180/

# Rename iPXE script for easier chainloading
sudo mv /srv/tftp/nixos-cix-cd8180/netboot.ipxe /srv/tftp/nixos-cix-cd8180/boot.ipxe
```

This places the following files in `/srv/tftp/nixos-cix-cd8180/`:
- `kernel` - Linux kernel
- `initrd` - Initial ramdisk  
- `boot.ipxe` - iPXE boot script (renamed from `netboot.ipxe`)

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

**Default credentials:**
- Username: `nixos`
- Password: `nixos`
- SSH: Enabled (port 22)

⚠️ **Change the password immediately after first boot:**
```bash
passwd              # Change user password
sudo passwd root    # Change root password
```

#### Network Boot Features

- Deploy to multiple boards
- No SD card or local storage required
- Update by replacing files on server
- Suitable for testing and development

#### Building from Source

If you want to build the netboot package yourself instead of using pre-built releases, see [Development Guide](development.md#building-images).

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

For NixOS configuration examples, see the [examples directory](../examples/):
- [Minimal Configuration](../examples/minimal.nix) - Basic setup
- [Desktop Configuration](../examples/desktop.nix) - Desktop environment with GPU support
- [AI Workstation](../examples/ai-workstation.nix) - Full setup with NPU, GPU, ISP drivers

Board-specific details: [Orange Pi 6 Plus Documentation](boards/orangepi-6-plus.md)

## Boot Modes

The system supports two boot modes selectable from GRUB menu:

### ACPI Mode (Default)
- Uses ACPI tables for hardware detection
- Better hardware abstraction layer
- Recommended for production use
- Kernel parameter: `acpi=force`

### Device Tree Mode
- Uses explicit device tree blob for hardware configuration
- Useful for debugging and development
- Alternative when ACPI has issues
- Kernel parameter: `acpi=off`
- DTB: `sky1-orangepi-6-plus.dtb`

Both modes have been tested and confirmed working on Orange Pi 6 Plus.

## Partition Layout

The SD card image uses the following partition layout:

```
Offset: 10 MiB (reserved for bootloader/firmware)
├─ Partition 1: ESP (FAT32, 200 MiB)
│  ├─ /EFI/BOOT/BOOTAA64.EFI - GRUB bootloader
│  ├─ /grub/grub.cfg - Boot configuration
│  ├─ /Image - Linux kernel
│  ├─ /initrd - Initial ramdisk
│  └─ /dtbs/cix/*.dtb - Device tree blobs
└─ Partition 2: Root (ext4, auto-resize on first boot)
   └─ NixOS root filesystem
```

## Troubleshooting

### Boot Issues

**System doesn't boot:**
- Verify UEFI firmware is present (pre-installed on Orange Pi 6 Plus)
- Check serial console output on ttyAMA2 for error messages
- Try Device Tree mode if ACPI mode fails

**Kernel panic during boot:**
- Ensure SD card is properly inserted and readable
- Verify image was flashed correctly (check with `dd if=/dev/sdX bs=512 count=1 | hexdump -C`)
- Check that root partition has NIXOS_SD label (`blkid /dev/sdX2`)

**GRUB menu doesn't appear:**
- Wait 2 seconds for auto-boot
- Check that ESP partition contains BOOTAA64.EFI

### First Use

**Nix commands slow on first run:**

First `nix shell` or `nix-shell` command can take 1-3 minutes - this is normal behavior.

A fresh NixOS system needs to:
1. Download and evaluate the nixpkgs flake registry
2. Fetch package metadata from cache.nixos.org
3. Download/build packages

**Recommendations:**
- Be patient on first use (subsequent commands will be fast)
- Use `nix shell nixpkgs#package` for better flake support
- Verify network: `ping cache.nixos.org`

For board-specific troubleshooting, see your board's documentation:
- [Orange Pi 6 Plus Troubleshooting](boards/orangepi-6-plus.md#troubleshooting)
