# Source: orangepi-xunlong/component_cix-next
{ mkCixDebPackage
, cix-component-srcs
, lib
,
}:

mkCixDebPackage {
  pname = "cix-llama-cpp";
  version = "1.2.4+2503.cix-next";
  debName = "cix-llama-cpp_1.2.4_arm64.deb";
  src = cix-component-srcs.component_cix-next;
  description = "LLaMA.cpp with NPU acceleration for CIX CD8180/CD8160 (28.8 TOPS)";
  license = lib.licenses.mit;
}
