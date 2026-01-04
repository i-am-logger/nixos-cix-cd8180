# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-libdrm";
  version = "1.0.0+2503.cix-next";
  debName = "cix-libdrm_1.0.0_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "DRM (Direct Rendering Manager) library for CIX CD8180/CD8160 GPU";
  license = lib.licenses.mit;
}
