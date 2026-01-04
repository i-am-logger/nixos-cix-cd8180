# Source: orangepi-xunlong/component_cix-next
# CIX vendor-specific tools
# Provides tools not available in standard nixpkgs
{ lib
, stdenv
, cix-component-srcs
, autoPatchelfHook
,
}:

stdenv.mkDerivation rec {
  pname = "cix-tools";
  version = "1.0.0+2503.cix-next";

  src = cix-component-srcs.component_cix-next;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Install vendor-specific tools only
    # For I2C/SPI/MTD/UART, use nixpkgs: i2c-tools, spi-tools, mtdutils, minicom/picocom
    install -m755 cix_binary/device/misc/usr/share/cix/bin/i3ctransfer $out/bin/
    install -m755 cix_binary/device/misc/usr/share/cix/bin/pmtool $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "CIX Sky1 SoC vendor-specific tools (i3ctransfer, pmtool)";
    longDescription = ''
      Vendor-specific tools for CIX Sky1 SoC:
      - i3ctransfer: I3C bus transfer tool (I3C is the successor to I2C)
      - pmtool: Power management CLI tool

      For other hardware interfaces, use standard nixpkgs packages:
      - I2C: i2c-tools (i2cdetect, i2cget, i2cset, i2cdump, i2ctransfer)
      - SPI: spi-tools (spidev_test, spidev_fdx)
      - MTD: mtdutils (mtd_debug, flash_erase, etc.)
      - UART: minicom, picocom, screen
    '';
    homepage = "https://github.com/orangepi-xunlong/component_cix-next";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
    maintainers = [ ];
  };
}
