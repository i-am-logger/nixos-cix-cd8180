# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-cpipe";
  version = "1.0.0+2503.cix-next";
  debName = "cix-cpipe_1.0.0_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "Camera pipeline for CIX CD8180/CD8160 ISP";
  license = lib.licenses.unfree;
}
