# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-mesa";
  version = "24.0.4+2503.cix-next";
  debName = "cix-mesa_24.0.4_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "Mesa 3D graphics library with Mali GPU support for CIX CD8180/CD8160";
  license = lib.licenses.mit;
}
