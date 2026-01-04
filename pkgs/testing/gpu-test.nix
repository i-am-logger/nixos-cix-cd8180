# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-gpu-test";
  version = "1.0.0+2503.cix-next";
  debName = "cix-gpu-test_1.0.0_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "GPU testing and benchmarking tools for Mali-G610 MP4";
  license = lib.licenses.unfree;
}
