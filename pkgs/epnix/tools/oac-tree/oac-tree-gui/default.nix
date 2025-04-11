{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
  qt6,
  libxml2,
  autoPatchelfHook,
  plugins ? [],
}:
stdenv.mkDerivation {
  pname = "oac-tree-gui";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/oac-tree-gui.zip";
    hash = "sha256-riZw9xmCNLZn6+7JL4Wa8yysxrA12rAY7UVnvSz5RYA=";
  };

  nativeBuildInputs = [
    cmake
    # Needed... because libca.so and libpvxs can't be found at runtime...
    autoPatchelfHook
  ];
  buildInputs =
    [
      gtest
      qt6.full

      epnix.support.pvxs
      epnix.epics-base

      epnix.sup-gui-core
      epnix.sup-dto
      epnix.sup-mvvm
      epnix.sup-gui-extra
      epnix.oac-tree
      epnix.sup-utils
      epnix.oac-tree-server
      epnix.sup-protocol
      epnix.sup-di
      epnix.sup-epics
      libxml2
    ]
    ++ plugins;

  autoPatchelfIgnoreMissingDeps = ["*"];
  extraAutoPatchelfLibs = ["${epnix.epics-base7}/lib/linux-x86_64/" "${epnix.support.pvxs}/lib/linux-x86_64/"];
}
