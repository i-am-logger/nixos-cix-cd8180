# Desktop configuration with GPU acceleration for Orange Pi 6 Plus
# Includes window manager and basic desktop applications
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:logger/nixos-cix-cd8180";
  };

  outputs = { nixpkgs, nixos-cix-cd8180, ... }: {
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

          # Enable OpenGL (required for GPU acceleration)
          hardware.opengl = {
            enable = true;
            driSupport = true;

            # TODO: Uncomment when GPU drivers are accessible
            # package = pkgs.cix-gpu-umd;
          };

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
  };
}
