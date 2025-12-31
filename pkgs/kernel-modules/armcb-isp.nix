# ARM Camera Block ISP kernel driver for CIX CD8180/CD8160 SoC
# Source: cix_opensource/isp/isp_driver

{ lib
, stdenv
, fetchFromGitHub
, kernel
}:

let
  componentSrc = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "component_cix-current";
    rev = "be5fa75cc218bb10ab6c9064a3562fab97792ec2";
    hash = "sha256-rPGsnIzGou+Fp6DTMbJQ/fhUmdzfE/nenmbTc7avsaw=";
  };
in
stdenv.mkDerivation {
  pname = "armcb-isp-driver";
  version = "1.0.0+2503.orangepi";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/isp/isp_driver";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  preBuild = ''
    # ISP Makefile uses $(PWD) for M= and PATH_ROOT for kernel path
    makeFlagsArray+=(
      "EXTRA_CFLAGS+=-I$(pwd)/platform -I$(pwd)/common -I$(pwd)/common/isp_hw_if -I$(pwd)/sensor -I$(pwd)/isp -I$(pwd)/platform/logger -I$(pwd)/cixvihw"
    )
  '';

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "PATH_ROOT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/media/ 2>/dev/null || true
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "ARM Camera Block ISP kernel driver for CIX CD8180/CD8160 SoC (Sky1)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
