# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-mnn";
  version = "1.2.1+2503.cix-next";
  debName = "cix-mnn_1.2.1_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "MNN neural network framework with NPU acceleration for CIX CD8180/CD8160";
  license = lib.licenses.asl20;
}
