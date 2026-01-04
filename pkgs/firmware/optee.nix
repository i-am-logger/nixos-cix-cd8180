# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-optee";
  version = "1.0.0+2503.cix-next";
  debName = "cix-optee_1.0.0_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "OP-TEE Trusted Execution Environment for CIX CD8180/CD8160 (secure boot, DRM)";
  license = lib.licenses.bsd2;
}
