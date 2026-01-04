# MVX Video Processing Unit (VPU) kernel driver for CIX CD8180/CD8160 SoC
# Source: cix_opensource/vpu/vpu_driver

{ lib
, stdenv
, cix-component-srcs
, kernel
,
}:

let
  componentSrc = cix-component-srcs.component_cix-next;
in
stdenv.mkDerivation {
  pname = "mvx-vpu-driver";
  version = "1.0.0+2503.radxa";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/vpu/vpu_driver/driver";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media/ 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "MVX Video Processing Unit (VPU) kernel driver for CIX CD8180/CD8160 SoC (Sky1)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
