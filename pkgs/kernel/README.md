# Kernel Packages for CIX CD8180/CD8160 (Sky1) SoC

## Available Kernels

### vendor.nix (Recommended)

Vendor kernel from orangepi-xunlong/linux-orangepi

- GPU, NPU (28.8 TOPS), ISP, VPU, and GPIO support
- All CIX Sky1 hardware supported
- Device trees included for CIX Sky1-based boards

### mainline.nix

**Linux 6.19+** from torvalds/linux

- Basic CIX CD8180/CD8160 (Sky1) SoC support
- No proprietary drivers (GPU/NPU/ISP/VPU/GPIO)
- Limited board device tree support

## Kernel Selection

The Orange Pi 6 Plus board module uses the vendor kernel by default for full hardware support.

### Default: Vendor Kernel

The `nixosModules.boards.orangepi6plus` module automatically configures:

```nix
boot.kernelPackages = pkgs.cixSky1VendorKernelPackages;
```

This provides GPU, NPU (28.8 TOPS), ISP, VPU, and GPIO support.

### Override with Mainline Kernel

To use a different kernel, override in your configuration:

```nix
{
  # Override the vendor kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
```

Note: Mainline kernels lack GPU/NPU/ISP/VPU/GPIO drivers.

## Generating Vendor Kernel Configuration

The vendor kernel uses a pre-generated configuration from the Orange Pi defconfig. To regenerate or customize:

```bash
# 1. Enter development environment
nix develop .#kernel

# 2. Clone kernel source (if not already available)
git clone --depth 1 -b orange-pi-6.1-cix \
  https://github.com/orangepi-xunlong/linux-orangepi.git /tmp/sky1-kernel

# 3. Generate base config
cd /tmp/sky1-kernel
make ARCH=arm64 CROSS_COMPILE=aarch64-unknown-linux-gnu- orangepi_6_plus_defconfig

# 4. Optionally customize (verify NixOS essentials are enabled)
make ARCH=arm64 CROSS_COMPILE=aarch64-unknown-linux-gnu- menuconfig

# Essential for NixOS (already enabled in vendor defconfig):
#   CONFIG_DEVTMPFS=y
#   CONFIG_DEVTMPFS_MOUNT=y
#   CONFIG_CGROUPS=y
#   CONFIG_INOTIFY_USER=y
#   CONFIG_EFI=y
#   CONFIG_EFI_STUB=y

# 5. Copy configuration to repository
cp .config /path/to/nixos-cix-cd8180/pkgs/kernel/sky1_vendor_config
```

## Device Trees

The vendor kernel includes device trees for all Cix Sky1-based boards. They are automatically installed to `$out/dtbs/`:

- `sky1-orangepi-6-plus.dtb`
- `sky1-orangepi-6-plus-40pin.dtb`
- `sky1-orion-o6.dtb`
- Others as available

## References

- Vendor kernel: https://github.com/orangepi-xunlong/linux-orangepi/tree/orange-pi-6.1-cix
- Mainline Cix Sky1 support: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/boot/dts/cix
