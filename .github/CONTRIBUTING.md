# Contributing to nixos-cix-cd8180

Thank you for your interest in contributing! This project provides NixOS support for CIX CD8180/CD8160 (Sky1) based single-board computers.

## Areas Needing Help

- [ ] **Hardware testing** on Orange Pi 6 Plus
- [ ] **Support for Radxa Orion O6**
- [ ] **Driver testing and documentation** (GPU, NPU, ISP, VPU)
- [ ] **Performance optimization**
- [ ] **Documentation improvements**

## How to Contribute

### Reporting Issues

- Search existing issues before creating a new one
- Include hardware details (board model, SoC version)
- Provide logs and error messages
- Describe expected vs actual behavior

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the code style guidelines (see below)
4. Format code with `nixpkgs-fmt .`
5. Test your changes locally
6. Commit with clear messages
7. Push to your fork
8. Open a Pull Request

### Development Setup

See [Development Guide](../docs/development.md) for detailed setup instructions.

Quick start:
```bash
git clone https://github.com/YOUR-USERNAME/nixos-cix-cd8180
cd nixos-cix-cd8180
nix develop  # Enter development shell
nixpkgs-fmt .  # Format code
nix flake check  # Validate changes
```

## Code Guidelines

### Nix Code Style

- Use `nixpkgs-fmt` for formatting (enforced in CI)
- Follow nixpkgs conventions
- Pin all external sources with `fetchFromGitHub` + hash
- Add source attribution comments
- Use kebab-case for package names, camelCase for Nix attributes
- See [Development Guide](../docs/development.md#code-style) for more details

### Commit Messages

- Use clear, descriptive commit messages
- Reference issues when applicable
- Format: `component: brief description`
- Examples:
  - `kernel: add RTL WiFi driver patches`
  - `docs: update installation guide`
  - `ci: enable ccache for faster builds`

## Testing

### Required Testing

- All builds must pass CI (nixpkgs-fmt, flake check, builds)
- Test on real hardware when possible
- Document testing results in PR

### Hardware Testing Checklist

When testing on real hardware:
- [ ] Board boots successfully
- [ ] Kernel loads without errors
- [ ] Network connectivity works
- [ ] Storage devices detected
- [ ] USB devices functional
- [ ] Serial console accessible

## License

By contributing, you agree that your contributions will be licensed under CC BY-NC-SA 4.0.

## Questions?

- Open an issue for questions
- Join discussions in existing issues/PRs
- Check [Development Guide](../docs/development.md)

## Code of Conduct

Be respectful, constructive, and collaborative. This is a community project.
