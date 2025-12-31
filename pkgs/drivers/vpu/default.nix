{ stdenvNoCC, fetchFromGitHub, lib }:

let
  componentSrc = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "component_cix-current";
    rev = "be5fa75cc218bb10ab6c9064a3562fab97792ec2";
    hash = "sha256-rPGsnIzGou+Fp6DTMbJQ/fhUmdzfE/nenmbTc7avsaw=";
  };
in
{
  # VPU firmware - the firmware files are the primary deliverable
  vpu-firmware = stdenvNoCC.mkDerivation {
    pname = "cix-vpu-firmware";
    version = "1.0.0+2503.radxa";

    src = "${componentSrc}/cix_proprietary/cix_proprietary-debs/cix-vpu-umd";

    dontBuild = true;
    dontFixup = true;
    compressFirmware = false;

    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/lib/firmware
      
      # Copy VPU firmware files
      if [ -d usr/lib/firmware ]; then
        cp -a usr/lib/firmware/* $out/lib/firmware/
      fi
      
      runHook postInstall
    '';

    meta = with lib; {
      description = "VPU (Video Processing Unit) firmware for cix CD8180/CD8160 SoC";
      homepage = "https://github.com/orangepi-xunlong/component_cix-current";
      license = licenses.unfree;
      platforms = [ "aarch64-linux" ];
    };
  };
}
