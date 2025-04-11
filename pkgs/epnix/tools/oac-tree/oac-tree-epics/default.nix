{
  stdenv,
  epnix,
  cmake,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "oac-tree-epics";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/941d0b1fc6c43ac0259610b655af212e1ccec41e/oac-tree-epics.zip";
    hash = "sha256-HDfQ1sVYPYybk+M8Uq4N8fB9mDJcaa8mcNzv+sSOf2Q=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.sup-dto
    epnix.sup-utils
    epnix.sup-protocol
    epnix.sup-epics
    epnix.sup-di
    epnix.oac-tree
  ];
}
