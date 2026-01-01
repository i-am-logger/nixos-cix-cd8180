# Minimal headless configuration
# Works with any CIX CD8180/CD8160 based board
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };

  outputs = { self, nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Choose your board:
        nixos-cix-cd8180.nixosModules.orangepi6plus
        # nixos-cix-cd8180.nixosModules.radxaoriono6  # (when available)

        {
          networking.hostName = "nixos";

          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "no";
          };

          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "nixos";
          };

          environment.systemPackages = with nixpkgs.legacyPackages.aarch64-linux; [
            vim
            git
            htop
            tmux
          ];

          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 22 ];
          };

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
