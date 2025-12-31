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
  pname = "cix-gpu-umd";
  version = "2.0.0+2503.orangepi";

  src = "${componentSrc}/cix_proprietary/cix_proprietary-debs/cix-gpu-umd";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out
    cp -a * $out/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mali-G610 MP4 GPU userspace drivers for cix CD8180/CD8160 SoC";
    homepage = "https://github.com/orangepi-xunlong/component_cix-current";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
  };
}
