# Desktop configuration with XFCE
# Works with any CIX CD8180/CD8160 based board
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };

  outputs = { self, nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Choose your board:
        nixos-cix-cd8180.nixosModules.orangepi6plus
        # nixos-cix-cd8180.nixosModules.radxaoriono6  # (when available)

        {
          networking.hostName = "desktop";

          # Enable X11 and window manager
          services.xserver = {
            enable = true;
            displayManager.lightdm.enable = true;
            desktopManager.xfce.enable = true;

            # Keyboard layout
            xkb.layout = "us";
          };

          # Enable graphics (Mali-G610 MP4 drivers configured via board module)
          hardware.graphics.enable = true;

          # Enable sound
          sound.enable = true;
          hardware.pulseaudio.enable = true;

          # Networking
          networking.networkmanager.enable = true;

          # User configuration
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
            initialPassword = "nixos";
          };

          # Desktop applications
          environment.systemPackages = with nixpkgs.legacyPackages.aarch64-linux; [
            firefox
            vlc
            gimp
            libreoffice

            # System utilities
            htop
            neofetch
            vim
            git
          ];

          # Enable automatic login (optional, for kiosk mode)
          # services.xserver.displayManager.autoLogin = {
          #   enable = true;
          #   user = "orangepi";
          # };

          system.stateVersion = "26.05";
        }
      ];
    };

    # Build: nix build .#sdImage or nix build .#netboot
    packages.aarch64-linux = {
      sdImage = nixos-cix-cd8180.packages.aarch64-linux.orangepi6plus-sdImage;
      netboot = nixos-cix-cd8180.packages.aarch64-linux.orangepi6plus-netboot;
    };
  };
}
