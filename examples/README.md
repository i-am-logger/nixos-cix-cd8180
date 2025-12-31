# Example Configurations

This directory contains example NixOS configurations for the Orange Pi 6 Plus.

## Available Examples

### 1. [minimal.nix](./minimal.nix) - Headless Server
**Use case**: Servers, home automation, IoT gateway

Features:
- Minimal package set
- SSH enabled
- Vendor kernel for hardware support
- Basic firewall
- Single user account

**Build**:
```bash
nix build .#boards-orangepi6plus-sdImage
# or the long form:
# nix build .#nixosConfigurations.orangepi6plus.config.system.build.sdImage
```

### 2. [desktop.nix](./desktop.nix) - Desktop Environment
**Use case**: Daily driver desktop, media center, workstation

Features:
- XFCE desktop environment
- GPU acceleration (when drivers available)
- Audio support
- Network Manager
- Common desktop applications (Firefox, LibreOffice, VLC, GIMP)

**Requirements**:
- Vendor kernel (for GPU support)
- Monitor connected via HDMI
- Keyboard and mouse

### 3. [ai-workstation.nix](./ai-workstation.nix) - AI/ML Development
**Use case**: Machine learning, AI development, NPU testing

Features:
- Python 3 with ML frameworks (NumPy, SciPy, Pandas, Matplotlib)
- Jupyter notebooks
- Docker support for containerized workloads
- NPU drivers (28.8 TOPS - when available)
- Remote access via SSH
- Optimized kernel parameters for ML workloads

**Ports opened**:
- 22: SSH
- 8888: Jupyter
- 6006: TensorBoard

## How to Use

### Method 1: Copy and Customize

1. Copy an example to your project:
```bash
cp examples/minimal.nix my-config/flake.nix
```

2. Customize for your needs:
```nix
{
  # Change hostname
  networking.hostName = "my-server";
  
  # Add your SSH keys
  users.users.pi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA..."
  ];
  
  # Add more packages
  environment.systemPackages = with pkgs; [
    # your packages here
  ];
}
```

3. Build:
```bash
nix build .#boards-orangepi6plus-sdImage
```

### Method 2: Import as Module

Use the nixos-cix-cd8180 flake as an input and import the board module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };

  outputs = { nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-cix-cd8180.nixosModules.boards.orangepi6plus
        ./configuration.nix
      ];
    };
  };
}
```

## Configuration Tips

### Hardware Drivers

The Orange Pi 6 Plus board module automatically includes:
- Vendor kernel (6.1.44-sky1) with all hardware drivers
- GPU (Mali-G610 MP4), NPU (28.8 TOPS), ISP, and VPU drivers
- Firmware packages (cix-firmware, cix-vpu-firmware)
- Hardware tools (cix-tools, orangepi-config, wiringop)

No additional configuration needed for basic hardware support.

### GPU Acceleration

```nix
# GPU drivers (cix-gpu-umd) are available in systemPackages
# Hardware acceleration integration is untested
hardware.graphics = {
  enable = true;
  # package = pkgs.cix-gpu-umd;  # May require package restructuring
};
```

**Note**: GPU drivers are packaged but untested. The cix-gpu-umd package may need restructuring for proper NixOS integration.

### Using Mainline Kernel

```nix
# Override to use mainline kernel (some hardware may not work)
boot.kernelPackages = pkgs.linuxPackages_latest;
```

### Network Boot (PXE)

For diskless systems, use the netboot module instead:

```nix
{
  imports = [
    nixos-cix-cd8180.nixosModules.orangepi6plus.netboot
  ];
}
```

## Testing Your Configuration

Before flashing to SD card:

```bash
# Check syntax
nix flake check

# Build to verify
nix build .#boards-orangepi6plus-sdImage --dry-run
```

## Common Issues

### Kernel doesn't boot

The Orange Pi 6 Plus board module uses the vendor kernel by default. If you overrode it, ensure your kernel has proper aarch64 support and required drivers.

### No display output

Check HDMI connection and ensure GPU drivers are loaded (requires vendor kernel).

## Contributing

Have a useful configuration? Submit a PR with:
- Descriptive filename (e.g., `nas-server.nix`)
- Comments explaining the use case
- List of features in this README

## Resources

- [Main README](../README.md)
- [Kernel Documentation](../pkgs/kernel/README.md)
- [Driver Documentation](../pkgs/drivers/README.md)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
