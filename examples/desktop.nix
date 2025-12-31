# Desktop configuration with GPU acceleration for Orange Pi 6 Plus
# Includes window manager and basic desktop applications
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:logger/nixos-cix-cd8180";
  };

  outputs = { self, nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.orangepi6plus = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        nixos-cix-cd8180.nixosModules.boards.orangepi6plus

        {
          networking.hostName = "orangepi-desktop";

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

    # Convenience packages for easier building
    packages.aarch64-linux = {
      default = self.nixosConfigurations.orangepi6plus.config.system.build.toplevel;
      sdImage = self.nixosConfigurations.orangepi6plus.config.system.build.sdImage;
    };
  };
}
