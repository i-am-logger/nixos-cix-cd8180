# NixOS CIX CD8180/CD8160 Boot Success Report

## Status: ✅ SUCCESSFULLY BOOTING

**Date**: January 3, 2026
**Board**: Orange Pi 6 Plus (CIX CD8180/CD8160 SoC)
**NixOS Version**: 26.05.20251228.c0b0e0f

## Boot Modes Tested

### ✅ ACPI Mode (Default)
- **Status**: Working
- **Kernel Parameters**: `acpi=force`
- **Use Case**: Production default, better hardware abstraction

### ✅ Device Tree Mode
- **Status**: Working  
- **Kernel Parameters**: `acpi=off`
- **DTB**: `sky1-orangepi-6-plus.dtb`
- **Use Case**: Explicit hardware configuration, debugging

## Boot Architecture

### UEFI Boot Flow
```
UEFI Firmware (NOR Flash)
    ↓
GRUB2 EFI (BOOTAA64.EFI - Vendor Binary)
    ↓
GRUB loads: Kernel + Initrd + DTB (optional)
    ↓
Linux Kernel 6.6.89-sky1
    ↓
NixOS Init System
    ↓
Login Prompt
```

### ESP Partition Contents
```
/EFI/BOOT/BOOTAA64.EFI    # Vendor GRUB (704 KB)
/grub/grub.cfg             # Generated GRUB config
/Image                     # Linux kernel (38 MB)
/initrd                    # NixOS initramfs (9.3 MB)
/dtbs/cix/*.dtb           # Device tree blobs (5 variants)
```

### Critical Boot Parameters
```bash
console=ttyAMA2,115200      # Serial console (PL011 UART)
efi=noruntime               # Disable EFI runtime services
earlycon=pl011,0x040d0000  # Early console
arm-smmu-v3.disable_bypass=0  # IOMMU
cma=640M                    # Contiguous Memory (GPU/VPU)
pcie_aspm=off               # PCIe stability (NVMe)
loglevel=4                  # Warning level
root=LABEL=NIXOS_SD         # Root filesystem
```

## Implementation Details

### The NixOS Way
- **Bootloader**: Vendor GRUB binary (cross-compilation workaround)
- **Kernel**: Vendor 6.6.89 with CIX patches
- **Initramfs**: NixOS-generated with all drivers
- **Partition Layout**: GPT with 10 MiB offset
- **Root Detection**: Label-based (`LABEL=NIXOS_SD`)

### Key Decisions
1. **Used vendor GRUB**: NixOS GRUB has perl cross-compilation issues
2. **ACPI default**: Matches vendor's production configuration
3. **Device Tree fallback**: Available for debugging/development
4. **Initrd in ESP**: Vendor layout, GRUB loads it properly

## Debugging Journey

### Issue 1: GRUB Cross-Compilation
**Problem**: NixOS GRUB with perl dependencies fails to cross-compile
**Solution**: Package and use vendor's GRUB EFI binary

### Issue 2: Kernel Panic - No Root Device
**Problem**: `VFS: Unable to mount root fs on unknown-block(0,0)`
**Solution**: Added `root=LABEL=NIXOS_SD` to kernel parameters

### Issue 3: Still Kernel Panic
**Problem**: No initramfs loaded, SD card driver not available
**Solution**: Added `initrd /initrd` to GRUB config

### Result: ✅ Successful Boot

## Hardware Status

### Working
- ✅ UEFI firmware
- ✅ GRUB bootloader
- ✅ Kernel boot (ACPI & DT modes)
- ✅ Serial console (ttyAMA2)
- ✅ Root filesystem mount
- ✅ NixOS init system

### To Be Tested
- [ ] Network (Ethernet/WiFi)
- [ ] GPU (Mali)
- [ ] NPU (28.8 TOPS)
- [ ] VPU (Video decode/encode)
- [ ] ISP (Camera)
- [ ] NVMe (if populated)
- [ ] USB
- [ ] GPIO

## Next Steps

1. **Hardware validation**: Test all peripherals
2. **Driver verification**: Ensure all kernel modules load
3. **Performance testing**: GPU/NPU/VPU functionality
4. **Documentation**: Update installation guide
5. **CI/CD**: Automate SD image builds
6. **Release**: Tag stable version

## Files Modified

```
pkgs/kernel/vendor.nix                       # DTB export
pkgs/firmware/grub-efi.nix                   # NEW: Vendor GRUB
modules/soc-cix-sky1/overlays.nix           # Add GRUB package
modules/boards/orangepi6plus/hardware.nix    # Boot config
modules/sd-image/default.nix                 # ESP setup
AGENTS.md                                    # Boot documentation
```

## Acknowledgments

- **Vendor**: Orange Pi (orangepi-xunlong) for firmware and kernel
- **NixOS Community**: For excellent ARM64 support
- **Boot Architecture**: Following vendor's proven UEFI setup

---

**This implementation demonstrates NixOS's flexibility in adapting to vendor hardware requirements while maintaining the NixOS philosophy of reproducible, declarative system configuration.**
