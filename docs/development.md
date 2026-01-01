# Development Guide

Local development, building, and testing.

## Getting Started

```bash
# Clone repository
git clone https://github.com/i-am-logger/nixos-cix-cd8180
cd nixos-cix-cd8180

# Validate flake
nix flake check

# Build SD image (cross-compile recommended for x86_64 hosts)
nix build .#orangepi6plus-sdImage-cross --print-build-logs
```

For SoC component builds (kernel, drivers, firmware), see [CIX CD8180/CD8160 Documentation](cix-cd8180-cd8160.md).

## Build Performance with ccache

**ccache is enabled by default** for kernel builds. The first build takes ~35-40 minutes, but subsequent builds are much faster when using cached compilation objects.

### Local Setup

ccache uses `/tmp/ccache` for storing compiled objects:

```bash
# ccache is automatically configured via flake.nix
# No manual setup needed!

# Optional: Persist ccache across reboots
# Add to your NixOS configuration:
```

```nix
{
  programs.ccache = {
    enable = true;
    cacheDir = "/tmp/ccache";
  };

  # Persist across reboots (if using impermanence)
  fileSystems."/tmp/ccache" = {
    device = "/persist/cache/ccache";
    fsType = "none";
    options = [ "bind" ];
  };
}
```

### Build Times

- **First build**: ~35-40 minutes (populates ccache)
- **Incremental builds**: Much faster with ccache hits
- **Cache location**: `/tmp/ccache` (10 GB max)
- **Sandbox access**: Configured in `flake.nix`

### Monitoring ccache

Check ccache statistics during/after build:

```bash
# Build logs show ccache stats in postBuild phase
nix build .#kernel-cross --print-build-logs

# Manually check cache size
du -sh /tmp/ccache
```

## Development Commands

### Code Quality

```bash
# Format all Nix files
nixpkgs-fmt .

# Check formatting
nix-shell -p nixpkgs-fmt --run "nixpkgs-fmt --check ."

# Validate flake
nix flake check
```

### Building Board Images

```bash
# SD Card Image
nix build .#orangepi6plus-sdImage-cross --print-build-logs  # x86_64 → aarch64
nix build .#orangepi6plus-sdImage --print-build-logs        # aarch64 native

# Network Boot
nix build .#orangepi6plus-netboot-cross --print-build-logs  # x86_64 → aarch64
nix build .#orangepi6plus-netboot --print-build-logs        # aarch64 native

# Board Tools
nix build .#orangepi6plus-tools-cross  # orangepi-config, wiringop
```

### Building SoC Components

For kernel, drivers, firmware builds, see [CIX CD8180/CD8160 SoC Documentation](cix-cd8180-cd8160.md#soc-components).

### Development Shells

```bash
# General development shell
nix develop

# Kernel-specific development shell
nix develop .#kernel
```

## CI/CD Pipeline

GitHub Actions automatically builds and caches:

### Binary Caching
- **Cachix**: Stores complete Nix derivations ([i-am-logger.cachix.org](https://i-am-logger.cachix.org))
- **GitHub Actions Cache**: Stores ccache objects (10 GB, incremental compilation)

### Workflow Steps
1. Format check (nixpkgs-fmt)
2. Flake validation
3. Restore ccache from previous runs
4. Build SD image and netboot
5. Create GitHub Release (on push to master)
6. Save ccache for next run

### Cache Strategy

**Cachix** (Nix store):
- Complete kernel packages
- Driver packages
- Full system images
- Shared across all builds

**GitHub Actions Cache** (ccache):
- Compiled object files
- Speeds up kernel rebuilds
- 10 GB limit per repository
- Invalidated when kernel sources change

## Code Style

### Nix Code

- Use `nixpkgs-fmt` for all Nix files (enforced in CI)
- Follow nixpkgs conventions
- Pin all external sources with `fetchFromGitHub` + hash
- Add source attribution comments at top of files
- Use kebab-case for package names (`cix-gpu-umd`)
- Use camelCase for Nix attributes (`cixSky1VendorKernel`)

### Kernel Modules

- Use `kernel.moduleBuildDependencies` for dependencies
- Set `KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build`
- Always use `runHook preInstall` and `runHook postInstall`

### File Organization

- `pkgs/` - Package definitions
- `modules/boards/` - Board-specific configurations
- `modules/soc/` - SoC base configurations
- `examples/` - User configuration examples

## Testing

### Local Testing

```bash
# Build and test SD image in QEMU (aarch64)
# TODO: Add QEMU testing instructions

# Build and flash to SD card
nix build .#orangepi6plus-sdImage-cross
zstd -d result/sd-image/*.img.zst
sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

### Hardware Testing

See [Contributing Guidelines](../.github/CONTRIBUTING.md) for hardware testing procedures.

## Troubleshooting

### ccache Issues

If ccache isn't working:

```bash
# Check permissions
ls -la /tmp/ccache  # Should be 0770 root:nixbld

# Check sandbox access
grep extra-sandbox-paths flake.nix  # Should include /tmp/ccache

# Verify ccache wrapper
cat $(nix build .#kernel-cross --no-link --print-out-paths)/bin/gcc
```

### Build Failures

```bash
# Clean build (removes all caches)
nix build .#orangepi6plus-sdImage-cross --rebuild

# Verbose output
nix build .#orangepi6plus-sdImage-cross --print-build-logs --verbose
```

## Additional Resources

- [Installation Guide](installation.md)
- [Contributing Guidelines](../.github/CONTRIBUTING.md)
