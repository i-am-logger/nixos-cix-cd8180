# AI/ML workstation with NPU support
# Works with any CIX CD8180/CD8160 based board (all have 28.8 TOPS NPU)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cix-cd8180.url = "github:i-am-logger/nixos-cix-cd8180";
  };

  outputs = { self, nixpkgs, nixos-cix-cd8180, ... }: {
    nixosConfigurations.ai-workstation = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Choose your board:
        nixos-cix-cd8180.nixosModules.orangepi6plus
        # nixos-cix-cd8180.nixosModules.radxaoriono6  # (when available)

        {
          networking.hostName = "ai-workstation";

          # Enable SSH for remote development
          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = true;
              X11Forwarding = true;
            };
          };

          # User configuration
          users.users.ml = {
            isNormalUser = true;
            description = "Machine Learning User";
            extraGroups = [ "wheel" "networkmanager" "docker" ];
            initialPassword = "changeme";
          };

          # AI/ML development packages
          environment.systemPackages = with nixpkgs.legacyPackages.aarch64-linux; [
            # Python and ML frameworks
            (python3.withPackages (ps: with ps; [
              numpy
              scipy
              pandas
              matplotlib
              jupyter
              # Add NPU-specific packages as needed
              # tensorflow-lite
              # onnxruntime
            ]))

            # NPU drivers and tools (included via board module)

            # Development tools
            git
            vim
            tmux
            htop

            # Model deployment tools
            docker
            docker-compose
          ];

          # Enable Docker for containerized ML workloads
          virtualisation.docker = {
            enable = true;
            enableOnBoot = true;
          };

          # Increase shared memory for ML workloads
          boot.kernel.sysctl = {
            "kernel.shmmax" = 68719476736; # 64GB
            "kernel.shmall" = 4294967296;
          };

          # Networking for remote access
          networking = {
            networkmanager.enable = true;
            firewall = {
              enable = true;
              allowedTCPPorts = [
                22 # SSH
                8888 # Jupyter
                6006 # TensorBoard
              ];
            };
          };

          # Optional: Jupyter server as a service
          # systemd.services.jupyter = {
          #   description = "Jupyter Notebook Server";
          #   after = [ "network.target" ];
          #   wantedBy = [ "multi-user.target" ];
          #   serviceConfig = {
          #     Type = "simple";
          #     User = "ml";
          #     WorkingDirectory = "/home/ml";
          #     ExecStart = "${pkgs.python3.withPackages(ps: [ps.jupyter])}/bin/jupyter notebook --ip=0.0.0.0 --no-browser";
          #     Restart = "on-failure";
          #   };
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
