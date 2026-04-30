{
  mkEpicsPackage,
  fetchFromGitHub,
  asyn,
  autoparamDriver,
  boost,
  epnixLib,
  lib,
}:
mkEpicsPackage rec {
  pname = "adsDriver";
  version = "3.2.0";

  varname = "ADS_DRIVER";

  src = fetchFromGitHub {
    owner = "Cosylab";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-xKfB1Za7xWwbpjhHlznDkSlTaXvpvpA/NhA7QDh/ZDQ=";
  };

  nativeBuildInputs = [ boost ];
  buildInputs = [ boost ];
  propagatedBuildInputs = [
    asyn
    autoparamDriver
  ];

  meta = {
    description = "EPICS support module for integrating Beckhoff PLC using the ADS protocol";
    homepage = "https://epics.cosylab.com/documentation/adsDriver/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [ synthetica ];
  };
}
