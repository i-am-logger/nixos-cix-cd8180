{ stdenvNoCC, fetchFromGitHub, lib }:

let
  componentSrc = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "component_cix-current";
    rev = "be5fa75cc218bb10ab6c9064a3562fab97792ec2";
    hash = "sha256-rPGsnIzGou+Fp6DTMbJQ/fhUmdzfE/nenmbTc7avsaw=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "cix-firmware";
  version = "1.0.0+2503.orangepi";

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
    description = "Firmware files for CIX CD8180/CD8160 SoC (GPU, NPU, ISP, VPU, WiFi, Bluetooth)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
  };
}
