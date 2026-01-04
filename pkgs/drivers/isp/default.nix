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
  pname = "cix-isp-umd";
  version = "1.0.0+2503.cix-next";

  src = "${componentSrc}/cix_proprietary/cix_proprietary-debs/cix-isp-umd";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a * $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "ISP (Image Signal Processor) userspace drivers for cix CD8180/CD8160 SoC";
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
  };
}
