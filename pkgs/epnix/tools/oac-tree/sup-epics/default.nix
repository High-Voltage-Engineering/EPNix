{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
  libxml2,
}:
stdenv.mkDerivation rec {
  pname = "sup-epics";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-epics.zip";
    hash = "sha256-tB4ErvZt8a8/IbNvHQ3h0800JsdvHghWkoQGp/lsJMo=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.epics-base7
    epnix.sup-dto
    epnix.sup-protocol
    epnix.sup-di
    epnix.support.pvxs
  ];

  EPICS_BASE = "${epnix.epics-base7}";

  # XXX: how to do this properly?
  EPICS_HOST_ARCH = "linux-x86_64";
  PVXS_DIR = "${epnix.support.pvxs}";

  # postPatch = ''
  #   grep -r pvxs . --context 10
  #   exit 1
  # '';
}
