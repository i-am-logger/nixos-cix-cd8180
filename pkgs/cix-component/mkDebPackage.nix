# Helper function to build packages from .deb files in component_cix-next
# Used for GPU, VPU, multimedia, graphics, and AI packages

{ lib
, stdenvNoCC
, dpkg
,
}:

{ pname
, version
, debName
, src
, description
, license ? lib.licenses.unfree
, homepage ? "https://github.com/orangepi-xunlong/component_cix-next"
, platforms ? [ "aarch64-linux" ]
, maintainers ? [ ]
, extraInstallPhase ? ""
, ...
}@args:

stdenvNoCC.mkDerivation (
  {
    inherit pname version;

    src = src;

    nativeBuildInputs = [ dpkg ];

    dontBuild = true;
    dontFixup = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src/debs/${debName} .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -a * $out/

      ${extraInstallPhase}

      runHook postInstall
    '';

    meta = with lib; {
      inherit
        description
        license
        homepage
        platforms
        maintainers
        ;
    };
  }
    // removeAttrs args [
    "debName"
    "description"
    "license"
    "homepage"
    "platforms"
    "maintainers"
    "extraInstallPhase"
  ]
)
