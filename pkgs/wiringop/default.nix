# WiringOP - GPIO library and tools for Orange Pi boards
{ lib
, stdenv
, buildPackages
, fetchFromGitHub
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "wiringop";
  version = "2.58";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "orangepi-build";
    rev = "next"; # wiringpi deb is on next branch, not main
    hash = "sha256-rd+rz/69NRzQ4kf5WkD2KwMf7SiarRp+a2o4mhaYE74=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    buildPackages.stdenv.cc.bintools # Provides 'ar' command for extracting .deb
  ];

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
