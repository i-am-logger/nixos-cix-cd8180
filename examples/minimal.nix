# Minimal headless configuration for Orange Pi 6 Plus
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:logger/nixos-cix-cd8180";
  };

  outputs = { nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.orangepi6plus = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Board module (includes cix CD8180/CD8160 vendor kernel + drivers)
        nixos-cix-cd8180.nixosModules.boards.orangepi6plus

        {
          networking.hostName = "orangepi";

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
  };
}
