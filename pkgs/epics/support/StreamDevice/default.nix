{ lib
, mkEpicsPackage
, fetchgit
, version ? "2.8.20"
, sha256 ? ""
, epics
, pcre
, local_config_site ? { }
, local_release ? { }
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;
in
mkEpicsPackage {
  pname = "StreamDevice";
  inherit version;
  # TODO: is this correct?
  varname = "STREAM";

  inherit local_config_site;
  local_release = local_release // {
    PCRE = null;
    PCRE_INCLUDE = "${pcre.dev}/include";
    PCRE_LIB = "${pcre}/lib";

    # Removes warning about unused SUPPORT variable
    STREAM = null;
  };

  buildInputs = [ pcre ] ++ (with epics.support; [ asyn calc sscan ]);

  patches = [ ./printf-only-string-literal.patch ];

  src = fetchgit {
    url = "https://github.com/paulscherrerinstitute/StreamDevice.git";
    rev = version;
    sha256 = hash;
  };
}
