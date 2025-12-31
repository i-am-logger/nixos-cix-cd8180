{ stdenvNoCC, fetchFromGitHub, lib }:

let
  componentSrc = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "component_cix-current";
    rev = "be5fa75cc218bb10ab6c9064a3562fab97792ec2";
    hash = "sha256-rPGsnIzGou+Fp6DTMbJQ/fhUmdzfE/nenmbTc7avsaw=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "cix-npu-umd";
  version = "2.0.2";

  src = "${componentSrc}/cix_proprietary/cix_proprietary-debs/cix-noe-umd";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out
    cp -a * $out/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "NPU (Neural Processing Unit) userspace drivers for cix CD8180/CD8160 SoC - 28.8 TOPS";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
  };
}
