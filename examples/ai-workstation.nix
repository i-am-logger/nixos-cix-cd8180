# AI/ML workstation configuration for Orange Pi 6 Plus
# Optimized for NPU (28.8 TOPS) usage with machine learning frameworks
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
          networking.hostName = "orangepi-ai";

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

    # Convenience packages for easier building
    packages.aarch64-linux = {
      default = self.nixosConfigurations.orangepi6plus.config.system.build.toplevel;
      sdImage = self.nixosConfigurations.orangepi6plus.config.system.build.sdImage;
    };
  };
}
