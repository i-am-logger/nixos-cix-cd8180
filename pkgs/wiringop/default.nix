# WiringOP - GPIO library and tools for Orange Pi boards
{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "wiringop";
  version = "2.58";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "orangepi-build";
    rev = "f00cd197b4a9873f36093d4f4748b733642059a7";
    hash = "sha256-8Vqs08r9JAHBFnAkH6RWt1e/PhmUW26/62BVqaw1OL0=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ''
    runHook preUnpack
    
    # Extract the .deb file
    ar x ${src}/external/cache/debs/arm64/wiringpi-${version}-1.deb
    tar xf data.tar.xz
    
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    
    # Install from extracted .deb contents
    cp -r usr $out
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "GPIO library and tools for Orange Pi (WiringOP)";
    longDescription = ''
      WiringOP is a GPIO access library for Orange Pi boards.
      Includes the 'gpio' command for pin layout display and GPIO control.
    '';
    homepage = "https://github.com/orangepi-xunlong/wiringOP";
    license = licenses.lgpl3Plus;
    platforms = [ "aarch64-linux" ];
    maintainers = [ ];
  };
}
