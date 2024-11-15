{
  buildPythonPackage,
  pvxs,
  fetchPypi,
  setuptools_dso,
  epicscorelibs,
}:
buildPythonPackage rec {
  pname = "pvxslibs";
  inherit (pvxs) version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p9H6nK+iYJ5ML4x3wE0CmTq0sRFS4kGNgsyKEZPb2bU=";
  };

  configureScript = "true";

  nativeBuildInputs = [setuptools_dso epicscorelibs];

  inherit (pvxs) meta;
}
