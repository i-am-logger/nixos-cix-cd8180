# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-vpu-test";
  version = "1.0.0+2503.cix-next";
  debName = "cix-vpu-test_1.0.0_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "VPU (Video Processing Unit) testing tools for CIX CD8180/CD8160";
  license = lib.licenses.unfree;
}
