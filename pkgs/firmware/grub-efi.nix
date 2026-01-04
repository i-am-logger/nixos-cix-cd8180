# Source: orangepi-xunlong/component_cix-next
# GRUB2 EFI bootloader for CIX CD8180/CD8160 SoC

{ stdenvNoCC
, cix-component-srcs
, lib
,
}:

stdenvNoCC.mkDerivation {
  pname = "cix-grub-efi";
  version = "2.0.0+2503.cix-next";

  src = cix-component-srcs.component_cix-next;

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
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.gpl3Plus;
    platforms = [ "aarch64-linux" ];
    maintainers = [ ];
  };
}
