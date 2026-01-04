# Source: orangepi-xunlong/component_cix-next
{ stdenvNoCC
, cix-component-srcs
, lib
,
}:

let
  componentSrc = cix-component-srcs.component_cix-next;
in
{
  # VPU firmware - the firmware files are the primary deliverable
  vpu-firmware = stdenvNoCC.mkDerivation {
    pname = "cix-vpu-firmware";
    version = "1.0.0+2503.cix-next";

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
      homepage = "https://github.com/orangepi-xunlong/component_cix-next";
      license = licenses.unfree;
      platforms = [ "aarch64-linux" ];
    };
  };
}
