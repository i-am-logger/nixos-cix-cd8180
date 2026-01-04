# Mali-G610 MP4 GPU kernel driver for CIX CD8180/CD8160 SoC  
# Source: component_cix-next (official vendor source with Sky1 platform modifications)

{ lib
, stdenv
, fetchFromGitHub
, kernel
}:

let
  componentSrc = import ./cix-component-source.nix { inherit fetchFromGitHub; };
in
stdenv.mkDerivation {
  pname = "mali-gpu-driver";
  version = "1.0.0+2503.cix-next";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/gpu/gpu_kernel";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CONFIG_MALI_BASE_MODULES=y"
    "CONFIG_MALI_MEMORY_GROUP_MANAGER=y"
    "CONFIG_MALI_PROTECTED_MEMORY_ALLOCATOR=y"
    "CONFIG_MALI_PLATFORM_NAME=sky1"
    "CONFIG_MALI_CSF_SUPPORT=y"
    "CONFIG_MALI_CIX_POWER_MODEL=y"
  ];

  preBuild = ''
    # Use the Makefile from the DKMS package which sets all the right configs
    export MAKE="make CONFIG_MALI_BASE_MODULES=y CONFIG_MALI_MEMORY_GROUP_MANAGER=y CONFIG_MALI_PROTECTED_MEMORY_ALLOCATOR=y CONFIG_MALI_PLATFORM_NAME=sky1 CONFIG_MALI_CSF_SUPPORT=y CONFIG_MALI_CIX_POWER_MODEL=y"
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    
    # Install Mali driver
    find drivers/gpu/arm/midgard -name "*.ko" -exec cp {} $out/lib/modules/${kernel.modDirVersion}/extra/ \;
    
    # Install memory managers
    find drivers/base/arm -name "*.ko" -exec cp {} $out/lib/modules/${kernel.modDirVersion}/extra/ \;
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mali-G610 MP4 GPU kernel driver for CIX CD8180/CD8160 SoC (official DKMS source)";
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
