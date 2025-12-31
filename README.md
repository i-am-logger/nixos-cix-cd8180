# NixOS for CIX CD8180/CD8160 SoC (Sky1)

[![Build NixOS Images](https://github.com/i-am-logger/nixos-cix-cd8180/actions/workflows/build.yml/badge.svg)](https://github.com/i-am-logger/nixos-cix-cd8180/actions/workflows/build.yml)
[![Auto Update Dependencies](https://github.com/i-am-logger/nixos-cix-cd8180/actions/workflows/auto-update.yml/badge.svg)](https://github.com/i-am-logger/nixos-cix-cd8180/actions/workflows/auto-update.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-i--am--logger-blue.svg)](https://i-am-logger.cachix.org)
[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg)](https://nixos.org)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

**Pre-built Images**: [Latest Release](https://github.com/i-am-logger/nixos-cix-cd8180/releases/latest) - SD Card Image, Netboot (kernel + initrd + iPXE)

> ⚠️ Work in progress, use at your own risk...

NixOS flake for CIX CD8180/CD8160 (Sky1) based SBCs. Includes vendor kernel and proprietary drivers.

**Kernel**: Vendor kernel from orangepi-xunlong

## Boards

UEFI Boot Support:

| Single Board Computer | Boot from SD card  | Boot from NVMe SSD | Network Boot (PXE) |
| --------------------- | ------------------ | ------------------ | ------------------ |
| Orange Pi 6 Plus      | ✅ (building)      | ⚠️ (untested)      | ✅ (building)      |
| Radxa Orion O6        | ⚠️ (planned)       | ⚠️ (planned)       | ⚠️ (planned)       |

All boards use the CIX Sky1 SoC base configuration (`modules/soc/sky1.nix`) which includes kernel drivers and firmware. Board-specific modules only contain board-specific settings (console ports, GPIO tools, etc).

## Hardware Support Status (CIX Sky1 SoC)

| Component | Kernel Space | User Space | Status |
|-----------|--------------|------------|--------|
| **Ethernet** (RTL8126 2.5GbE) | ✅ r8169 (in-tree) | - | Working |
| **M.2 NVMe SSD** | ✅ nvme (in-tree) | - | Working |
| **USB 3.0/2.0** | ✅ xhci_pci (in-tree) | - | Working |
| **UEFI Boot** | ✅ Vendor firmware | - | Working |
| **GPU** (Mali-G610 MP4) | ✅ mali-gpu.ko (opensource) | ✅ cix-gpu-umd (proprietary) | Packaged, untested |
| **NPU** (28.8 TOPS) | ✅ aipu.ko (opensource) | ✅ cix-npu-umd (proprietary) | Packaged, untested |
| **ISP** (Camera) | ✅ armcb-isp.ko (opensource) | ✅ cix-isp-umd (proprietary) | Packaged, untested |
| **VPU** (Video codec) | ✅ mvx-vpu.ko (opensource) | ✅ Firmware (proprietary) | Packaged, untested |
| **WiFi/Bluetooth** | N/A (not on board) | ✅ Firmware (for USB dongles) | Packaged, untested |
| **Audio** | ✅ In-tree | - | Untested |
| **GPIO** | ✅ sysfs, cdev (in-tree) | - | Working |
| **I3C** | ✅ In-tree | ✅ i3ctransfer (proprietary) | Packaged, untested |
| **Power Management** | ✅ In-tree | ✅ pmtool (proprietary) | Packaged, untested |
| **UART/Serial** | ✅ In-tree | - | Working |

## Hardware Interface Tools

**Included in base system:**
- **I3C/Power**: `cix-tools` (i3ctransfer, pmtool) - Vendor-specific tools

**Available via nixpkgs (add to configuration.nix):**
- **I2C**: `i2c-tools` (i2cdetect, i2cget, i2cset, i2cdump, i2ctransfer)
- **SPI**: `spi-tools` (spidev_test, spidev_fdx)
- **MTD/Flash**: `mtdutils` (mtd_debug, flash_erase, nandwrite, etc.)
- **UART/Serial**: `minicom`, `picocom`, `screen`

## Orange Pi 6 Plus Board Tools

- [x] orangepi-config - hardware configuration tool
- [x] wiringop - GPIO library and utilities

## Installation

See [docs/installation.md](docs/installation.md) for detailed instructions on:
- SD Card Boot
- NVMe SSD installation  
- Network Boot (PXE)

## Usage

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
        nixos-cix-cd8180.nixosModules.boards.orangepi6plus
        ./configuration.nix
      ];
    };
  };
}
```

### Using NixOS Stable

To use a stable NixOS release instead of unstable:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";  # or nixos-25.05
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };
  # ... rest of config
}
```

Example configurations: [examples/](./examples/)

## Vendor Repositories

- **Kernel**: [orangepi-xunlong/linux-orangepi](https://github.com/orangepi-xunlong/linux-orangepi) (branch: `orange-pi-6.1-cix`)
- **Drivers/Firmware**: [orangepi-xunlong/component_cix-current](https://github.com/orangepi-xunlong/component_cix-current)
- **Build System/Tools**: [orangepi-xunlong/orangepi-build](https://github.com/orangepi-xunlong/orangepi-build) (includes orangepi-config)

## Acknowledgments

Inspired by and learned from:

- **[gnull/nixos-rk3588](https://github.com/gnull/nixos-rk3588)** - Kernel packaging, cross-compilation, module structure
- **[ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588)** (archived) - Initial flake structure
- [aciceri/rock5b-nixos](https://github.com/aciceri/rock5b-nixos)
- [nabam/nixos-rockchip](https://github.com/nabam/nixos-rockchip)

Thanks to the [NixOS on ARM Matrix group](https://matrix.to/#/#nixos-on-arm:nixos.org)

## Development

See [docs/development.md](docs/development.md) for:
- Building locally with ccache
- Development commands
- Code quality checks
- Testing procedures
- Troubleshooting

**Quick start:**
```bash
# Build with ccache (first build ~35-40 min, subsequent builds much faster)
nix build .#boards-orangepi6plus-sdImage-cross --print-build-logs
```

## Contributing

We welcome contributions! See [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md) for:
- How to contribute
- Code guidelines
- Testing requirements
- Pull request process

**Areas needing help:**
- Hardware testing on Orange Pi 6 Plus
- Support for Radxa Orion O6
- Driver testing and documentation

## License

**Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)**

See [LICENSE](./LICENSE) for details.

---

**Status**: Build in progress | Hardware testing pending | Community contributions welcome
