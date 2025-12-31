# MVX Video Processing Unit (VPU) kernel driver for CIX CD8180/CD8160 SoC
# Source: cix_opensource/vpu/vpu_driver

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
  pname = "mvx-vpu-driver";
  version = "1.0.0+2503.radxa";

  src = componentSrc;

  sourceRoot = "source/cix_opensource/vpu/vpu_driver/driver";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
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
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.gpl2;
    platforms = [ "aarch64-linux" ];
  };
}
