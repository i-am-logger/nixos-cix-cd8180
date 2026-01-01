# Orange Pi 6 Plus

Board-specific documentation for Orange Pi 6 Plus (CIX CD8180/CD8160 SoC).

**SoC Documentation**: See [CIX CD8180/CD8160](../cix-cd8180-cd8160.md) for kernel, drivers, firmware, and hardware specifications.

## Quick Start

**Build SD Card Image:**
```bash
# Cross-compile from x86_64 (recommended, first build ~35-40 min)
nix build .#orangepi6plus-sdImage-cross --print-build-logs

# Native build on aarch64
nix build .#orangepi6plus-sdImage --print-build-logs
```

**Flash to SD Card:**
```bash
zstd -d result/sd-image/*.img.zst
sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

See [Installation Methods](#installation-methods) below for NVMe and Network Boot options.

---

## Board Overview

- **SoC**: CIX CD8180/CD8160 (Sky1)
- **RAM**: 4GB / 8GB / 16GB LPDDR5
- **Storage**: MicroSD, NVMe M.2 2280
- **Network**: Realtek RTL8126 2.5GbE
- **USB**: 1x USB 3.0, 2x USB 2.0
- **Video**: HDMI 2.1 (4K@60Hz)
- **GPIO**: 40-pin header
- **Power**: USB-C PD, 5V/4A
- **Boot**: UEFI firmware (pre-installed)

## Board-Specific Components

### SD Card Image

**Build Commands:**

```bash
# Cross-compile from x86_64 (recommended)
nix build .#orangepi6plus-sdImage-cross

# Native build on aarch64
nix build .#orangepi6plus-sdImage

# With build logs
nix build .#orangepi6plus-sdImage-cross --print-build-logs
```

**Output**: `result/sd-image/nixos-sd-image-*.img.zst`

### Network Boot (Netboot)

**Build Commands:**

```bash
# Cross-compile from x86_64 (recommended)
nix build .#orangepi6plus-netboot-cross

# Native build on aarch64
nix build .#orangepi6plus-netboot

# With build logs
nix build .#orangepi6plus-netboot-cross --print-build-logs
```

**Output**: `result/{kernel,initrd,netboot.ipxe}`

### Board Tools

**Build Commands:**

```bash
# Cross-compile from x86_64 (recommended)
nix build .#orangepi6plus-tools-cross

# Native build on aarch64
nix build .#orangepi6plus-tools
```

**Included Tools:**
- `orangepi-config` - Hardware configuration utility
- `wiringop` - GPIO library and utilities

## Installation Methods

### Method 1: SD Card Boot

See [Installation Guide - SD Card](../installation.md#option-1-sd-card-boot) for detailed steps.

**Quick Start:**

```bash
# Build image
nix build .#orangepi6plus-sdImage-cross

# Flash to SD card
zstd -d result/sd-image/*.img.zst
sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

### Method 2: NVMe SSD Boot

See [Installation Guide - NVMe](../installation.md#option-2-boot-from-nvme-ssd) for detailed steps.

**Requirements:**
- Initial SD card boot
- NVMe M.2 SSD installed
- UEFI firmware (pre-installed)

### Method 3: Network Boot (PXE)

See [Installation Guide - Netboot](../installation.md#option-3-network-boot-pxe) for detailed steps.

**Quick Start:**

```bash
# Build netboot package
nix build .#orangepi6plus-netboot-cross

# Copy to PXE server
cp result/kernel /srv/tftp/nixos-cix-cd8180/kernel
cp result/initrd /srv/tftp/nixos-cix-cd8180/initrd
cp result/netboot.ipxe /srv/tftp/nixos-cix-cd8180/boot.ipxe
```

## Board Configuration

### Using in Your Flake

**With NixOS Unstable** (recommended):
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };

  outputs = { nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.orangepi6plus = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        nixos-cix-cd8180.nixosModules.orangepi6plus
        ./configuration.nix
      ];
    };
  };
}
```

**With NixOS Stable:**
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";  # or nixos-25.05
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };
  # ... same outputs as above
}
```

The board module automatically includes:
- CIX CD8180/CD8160 SoC base configuration
- Vendor kernel (Linux 6.6.89-sky1) with all hardware drivers
- Board-specific tools (orangepi-config, wiringop)
- Firmware packages



## Hardware Status

### Working ✅
- **Ethernet**: RTL8126 2.5GbE (r8169 driver)
- **NVMe**: M.2 SSD support (nvme driver)
- **USB**: USB 3.0/2.0 ports (xhci_pci driver)
- **UART/Serial**: Console access
- **GPIO**: sysfs, cdev access
- **UEFI Boot**: From SD card and NVMe

### Untested ⚠️
- **GPU**: Mali-G610 MP4 (drivers packaged)
- **NPU**: 28.8 TOPS (drivers packaged)
- **ISP**: Camera support (drivers packaged)
- **VPU**: Video codec (drivers packaged)
- **Audio**: HDMI audio, analog audio
- **WiFi/Bluetooth**: USB dongles (firmware packaged)

## Example Configurations

See [examples/](../../examples/) for generic configurations that work with any CIX CD8180/CD8160 board:

- **[minimal.nix](../../examples/minimal.nix)** - Headless server
- **[desktop.nix](../../examples/desktop.nix)** - XFCE desktop environment
- **[ai-workstation.nix](../../examples/ai-workstation.nix)** - ML/AI development with NPU

All examples include a board module selector - just uncomment your board.

## Troubleshooting

### Board won't boot from SD card

1. Verify UEFI firmware is installed (pre-installed on Orange Pi 6 Plus)
2. Check SD card is properly flashed: `sudo fdisk -l /dev/sdX`
3. Try a different SD card (some cards are incompatible)
4. Check UEFI boot menu (ESC or F12 during boot)

### No NVMe drive detected

1. Check M.2 SSD is properly seated
2. Verify NVMe support in UEFI settings
3. Check kernel messages: `dmesg | grep nvme`
4. Ensure NVMe is detected: `lsblk`

### Network boot fails

1. Verify DHCP server is responding
2. Check TFTP/HTTP server is accessible
3. Review UEFI network settings
4. Check firewall rules on PXE server
5. Verify iPXE script syntax

### No display output

1. Check HDMI cable connection
2. Try a different HDMI port/cable
3. Check monitor input selection
4. Verify GPU drivers are loaded (requires vendor kernel)
5. Check kernel logs: `dmesg | grep -i hdmi`

## GPIO Access

### Using Board Tools

```bash
# Install wiringop
nix-shell -p wiringop

# GPIO utilities
gpio readall      # Show GPIO status
gpio mode 1 out   # Set pin to output
gpio write 1 1    # Write high
gpio read 1       # Read pin state
```

### Sysfs Access

```bash
# Export GPIO
echo 510 > /sys/class/gpio/export

# Set direction
echo out > /sys/class/gpio/gpio510/direction

# Write value
echo 1 > /sys/class/gpio/gpio510/value
```

## References

- [CIX CD8180/CD8160 SoC Documentation](../cix-cd8180-cd8160.md) - Kernel, drivers, firmware
- [Installation Guide](../installation.md) - Detailed installation instructions
- [Development Guide](../development.md) - Building and development
- [Main README](../../README.md) - Project overview
- [Orange Pi 6 Plus Official Page](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-6-Plus.html)
