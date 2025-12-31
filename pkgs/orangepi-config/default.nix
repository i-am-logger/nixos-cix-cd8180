# Orange Pi hardware configuration tool
{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, bash
, coreutils
, gnugrep
, gnused
, util-linux
}:

stdenv.mkDerivation rec {
  pname = "orangepi-config";
  version = "unstable-2024-12-30";

  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "orangepi-build";
    rev = "main";
    hash = "sha256-8Vqs08r9JAHBFnAkH6RWt1e/PhmUW26/62BVqaw1OL0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    coreutils
    gnugrep
    gnused
    util-linux
  ];

  # Don't build, just install scripts
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/orangepi-config
    
    # Install orangepi-config and related scripts
    if [ -d external/cache/sources/orangepi-config ]; then
      install -m 755 external/cache/sources/orangepi-config/debian-config $out/bin/orangepi-config
      install -m 644 external/cache/sources/orangepi-config/debian-config-functions $out/lib/orangepi-config/
      install -m 755 external/cache/sources/orangepi-config/debian-config-functions-network $out/lib/orangepi-config/
      install -m 644 external/cache/sources/orangepi-config/debian-config-jobs $out/lib/orangepi-config/
      install -m 644 external/cache/sources/orangepi-config/debian-config-submenu $out/lib/orangepi-config/
      install -m 644 external/cache/sources/orangepi-config/debian-software $out/lib/orangepi-config/
    fi

    runHook postInstall
  '';

  postFixup = ''
    # Wrap orangepi-config with proper PATH
    if [ -f $out/bin/orangepi-config ]; then
      wrapProgram $out/bin/orangepi-config \
        --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused util-linux ]}
    fi
  '';

  meta = with lib; {
    description = "Hardware configuration tool for Orange Pi boards";
    homepage = "https://github.com/orangepi-xunlong/orangepi-build";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
