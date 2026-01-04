# Base NixOS configuration for Orange Pi 6 Plus
# Minimal headless system with terminal access only
{ config, pkgs, lib, ... }:

{
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic system packages for terminal use
  environment.systemPackages = with pkgs; [
    coreutils # Basic Unix utilities (cat, ls, head, tail, etc.)
    util-linux # More system utilities (lsblk, dmesg, etc.)
    pciutils # lspci
    usbutils # lsusb
    kmod # Kernel module utilities (lsmod, modprobe)
    vim
    nano
    wget
    curl
    git
    htop
    tmux
    neofetch
  ];

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Default user: nixos / password: nixos
  users.users.nixos = {
    isNormalUser = true;
    initialHashedPassword = lib.mkDefault "$6$Mmmdni26Ub5FExKY$bl.SQtKpgqVJmcNT/umFuMkzpYBjn2eEerXH0xH8izux7s9BGjy2nTDACuF91cMguzISVtELnYJC9jBGklzdn.";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    description = "NixOS User";
  };

  # Root user with same password for emergency access
  users.users.root.initialHashedPassword = lib.mkDefault "$6$Mmmdni26Ub5FExKY$bl.SQtKpgqVJmcNT/umFuMkzpYBjn2eEerXH0xH8izux7s9BGjy2nTDACuF91cMguzISVtELnYJC9jBGklzdn.";

  # Allow sudo without password (default image only - change in production!)
  security.sudo.wheelNeedsPassword = false;

  # Enable networking
  networking.networkmanager.enable = true;

  # No graphical interface - headless system
  # To add GUI later, see examples/desktop.nix

  # Set timezone (change as needed)
  time.timeZone = lib.mkDefault "UTC";

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
  };

  # Set system state version (do not change after initial install)
  system.stateVersion = "26.05";
}
