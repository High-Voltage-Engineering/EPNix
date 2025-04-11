{
  stdenv,
  epnix,
  cmake,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "oac-tree-server";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/941d0b1fc6c43ac0259610b655af212e1ccec41e/oac-tree-server.zip";
    hash = "sha256-CYKbEZViUQGWL9SaSN3HUdH5M7gkYsfH0gP0VZtttVM=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.sup-dto
    epnix.sup-utils
    epnix.sup-epics
    epnix.sup-protocol
    epnix.sup-di
    epnix.oac-tree
  ];
}
