# Orange Pi 6 Plus board-specific hardware configuration
# Board uses CIX Sky1 SoC (CD8180/CD8160) - see soc-cix-sky1/module.nix for SoC config
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../soc-cix-sky1/module.nix # CIX Sky1 SoC base configuration
  ];

  config = {
    # Orange Pi specific packages
    nixpkgs.overlays = [
      (final: prev: {
        orangepi-config = final.callPackage ../../../pkgs/orangepi-config { };
        wiringop = final.callPackage ../../../pkgs/wiringop { };
      })
    ];

    boot = {
      # UEFI boot
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      # Board-specific kernel parameters (serial console)
      kernelParams = [
        "console=ttyS2,1500000" # Orange Pi 6 Plus serial port
        "console=tty1" # HDMI
      ];
    };

    # Orange Pi board-specific tools (GPIO, hardware config)
    environment.systemPackages = with pkgs; [
      orangepi-config # Orange Pi hardware configuration tool
      wiringop # Orange Pi GPIO library and tools
    ];
  };
}
