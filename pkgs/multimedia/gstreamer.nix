# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-gstreamer";
  version = "1.22.1+2503.cix-next";
  debName = "cix-gstreamer_1.22.1_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "GStreamer with hardware acceleration for CIX CD8180/CD8160 (GPU/VPU)";
  license = lib.licenses.lgpl2Plus;
}
