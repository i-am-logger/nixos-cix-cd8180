# Shared source for CIX CD8180/CD8160 component drivers
# Using component_cix-next which has the latest working drivers with Sky1 modifications

{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "orangepi-xunlong";
  repo = "component_cix-next";
  rev = "d367489147a8b14b344d2b209fbc8ced8efaa007"; # Dec 30, 2025 - Update cix-alsa-conf
  hash = "sha256-kXgS0QxV7zUM2PtXnMkWvk7qN0Q9CCrR3FEEGj3fVzM=";
}
