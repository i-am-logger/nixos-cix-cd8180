# ARM China Zhouyi AIPU (NPU) kernel driver for CIX CD8180/CD8160 SoC
# Source: cix_opensource/npu/npu_driver

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
  pname = "aipu-npu-driver";
  version = "5.11.0";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/npu/npu_driver/driver";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "BUILD_AIPU_VERSION_KMD=BUILD_ZHOUYI_V3"
    "BUILD_TARGET_PLATFORM_KMD=BUILD_PLATFORM_SKY1"
    "BUILD_NPU_DEVFREQ=y"
  ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc
    cp aipu.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "ARM China Zhouyi AIPU (NPU) kernel driver - 28.8 TOPS for CIX CD8180/CD8160 SoC (Sky1)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
