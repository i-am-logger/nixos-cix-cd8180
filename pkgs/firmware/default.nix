# Source: orangepi-xunlong/component_cix-next
{ stdenvNoCC
, cix-component-srcs
, lib
,
}:

let
  componentSrc = cix-component-srcs.component_cix-next;
in
stdenvNoCC.mkDerivation {
  pname = "cix-firmware";
  version = "1.0.0+2503.cix-next";

  src = "${componentSrc}/cix_proprietary/cix_module_fw";

  dontBuild = true;
  dontFixup = true;
  compressFirmware = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware
    cp -a * $out/lib/firmware/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware files for CIX CD8180/CD8160 SoC (GPU, NPU, ISP, VPU, WiFi, Bluetooth, sensors)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
  };
}
