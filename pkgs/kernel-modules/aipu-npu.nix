# ARM China Zhouyi AIPU (NPU) kernel driver for CIX CD8180/CD8160 SoC
# Source: cix_opensource/npu/npu_driver

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
  pname = "aipu-npu-driver";
  version = "5.11.0";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/npu/npu_driver/driver";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  preBuild = ''
    # The Makefile uses $(PWD) for include paths, but we need absolute paths in Nix
    # Prepend EXTRA_CFLAGS with correct include paths and defines
    makeFlagsArray+=(
      "EXTRA_CFLAGS+=-I$(pwd)/armchina-npu/ -I$(pwd)/armchina-npu/include -I$(pwd)/armchina-npu/zhouyi -DKMD_VERSION=\\\"5.11.0\\\""
    )
  '';

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "COMPASS_DRV_BTENVAR_KPATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "BUILD_AIPU_VERSION_KMD=BUILD_ZHOUYI_V3"
    "BUILD_TARGET_PLATFORM_KMD=BUILD_PLATFORM_SKY1"
    "BUILD_NPU_DEVFREQ=y"
    "COMPASS_DRV_BTENVAR_KMD_VERSION=5.11.0"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc
    cp aipu.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc/

    runHook postInstall
  '';

  meta = with lib; {
    description = "ARM China Zhouyi AIPU (NPU) kernel driver - 28.8 TOPS for CIX CD8180/CD8160 SoC (Sky1)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
