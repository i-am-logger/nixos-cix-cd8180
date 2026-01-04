# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-libglvnd";
  version = "1.7.0+2503.cix-next";
  debName = "cix-libglvnd_1.7.0_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "OpenGL Vendor Neutral Dispatch library for CIX CD8180/CD8160";
  license = lib.licenses.mit;
}
