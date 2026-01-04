# GRUB2 EFI bootloader for CIX CD8180/CD8160 SoC
# Source: orangepi-xunlong/component_cix-current

{ stdenvNoCC, fetchFromGitHub, lib }:

stdenvNoCC.mkDerivation {
  pname = "cix-grub-efi";
  version = "2.0.0+2503.orangepi";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "component_cix-current";
    rev = "be5fa75cc218bb10ab6c9064a3562fab97792ec2";
    hash = "sha256-rPGsnIzGou+Fp6DTMbJQ/fhUmdzfE/nenmbTc7avsaw=";
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/EFI/BOOT
    cp grub.efi $out/EFI/BOOT/BOOTAA64.EFI
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "GRUB2 EFI bootloader for CIX CD8180/CD8160 SoC (vendor binary)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.gpl3Plus;
    platforms = [ "aarch64-linux" ];
    maintainers = [ ];
  };
}
