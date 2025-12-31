# Mali-G610 MP4 GPU kernel driver for CIX CD8180/CD8160 SoC
# Source: cix_opensource/gpu/gpu_kernel

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
  pname = "mali-gpu-driver";
  version = "1.0.0+2503.orangepi";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/gpu/gpu_kernel";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CONFIG_MALI_PLATFORM_NAME=sky1"
    "CONFIG_MALI_CSF_SUPPORT=y"
    "CONFIG_MALI_MEMORY_GROUP_MANAGER=y"
    "CONFIG_MALI_PROTECTED_MEMORY_ALLOCATOR=y"
  ];

  preBuild = ''
    cd drivers/base/arm
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      CONFIG_MALI_MEMORY_GROUP_MANAGER=y \
      modules
    cd ../../gpu/arm
  '';

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      ''${makeFlags[@]} \
      modules
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/gpu/arm
    
    # Install Mali driver
    cp drivers/gpu/arm/midgard/*.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/gpu/arm/ 2>/dev/null || true
    
    # Install memory group manager
    cp drivers/base/arm/*.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/gpu/arm/ 2>/dev/null || true
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mali-G610 MP4 GPU kernel driver for CIX CD8180/CD8160 SoC (Sky1)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
