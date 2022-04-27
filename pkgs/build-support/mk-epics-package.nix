{ stdenv
, lib
, runCommand
, makeWrapper
, perl
, epnix
, buildPackages
, pkgsBuildBuild
, writeText
, ...
}:

{ pname
, varname
, local_config_site ? { }
, local_release ? { }
, isEpicsBase ? false
, nativeBuildInputs ? [ ]
, buildInputs ? [ ]
, makeFlags ? [ ]
, passAsFile ? [ ]
, preBuild ? ""
, postInstall ? ""
, ...
} @ attrs:

with lib;
let
  inherit (buildPackages) epnixLib;

  # remove non standard attributes that cannot be coerced to strings
  overridable = builtins.removeAttrs attrs [ "local_config_site" "local_release" ];
  generateConf = (epnixLib.formats.make { }).generate;

  # "build" as in Nix terminology (the build machine)
  build_arch = epnixLib.toEpicsArch stdenv.buildPlatform;
  # "host" as in Nix terminology (the machine which will run the generated code)
  host_arch = epnixLib.toEpicsArch stdenv.hostPlatform;
in
stdenv.mkDerivation (overridable // {
  strictDeps = true;

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = nativeBuildInputs ++ [ makeWrapper perl ];
  buildInputs = buildInputs ++ (optional (!isEpicsBase) [ epnix.epics-base ]);

  makeFlags = makeFlags ++ [
    "INSTALL_LOCATION=${placeholder "out"}"

    # This prevents EPICS from detecting installed libraries on the host
    # system, for when Nix is compiling without sandbox (e.g.: WSL2)
    "GNU_DIR=/var/empty"
  ] ++ optional
    (stdenv.buildPlatform != stdenv.hostPlatform)
    "CROSS_COMPILER_TARGET_ARCHS=${host_arch}";

  setupHook = ./setup-hook.sh;

  enableParallelBuilding = attrs.enableParallelBuilding or true;

  dontConfigure = true;

  local_config_site = generateConf ({
      # This variable is used as a default version revision if no VCS is found.
      #
      # Since fetchgit and related fetchers remove the .git directory for
      # reproducibility, EPICS fallsback to either the GENVERSIONDEFAULT variable
      # if set (not the default), or the current date/time, which isn't
      # reproducible.
      GENVERSIONDEFAULT = "EPNix";
    }
    // local_config_site);

  # Undefine the SUPPORT variable here, since there is no single "support"
  # directory and this variable is a source of conflicts between RELEASE files
  local_release = generateConf (local_release // { SUPPORT = null; });

  passAsFile = passAsFile ++ [
    "local_config_site"
    "local_release"
  ];

  PERL_HASH_SEED = 0;

  preBuild = ''
    cp -fv --no-preserve=mode "$local_config_sitePath" configure/CONFIG_SITE.local
    cp -fv --no-preserve=mode "$local_releasePath" configure/RELEASE.local

    # set to empty if unset
    : "''${EPICS_COMPONENTS=}"

    IFS=: read -ra components <<<$EPICS_COMPONENTS

    for component in "''${components[@]}"; do
      echo "$component"
      echo "$component" >> configure/RELEASE.local
    done

    echo "=============================="
    echo "CONFIG_SITE.local"
    echo "------------------------------"
    cat "configure/CONFIG_SITE.local"
    echo "=============================="
    echo "RELEASE.local"
    echo "------------------------------"
    cat "configure/RELEASE.local"
    echo "------------------------------"

  '' + preBuild;

  # Automatically create binaries directly in `bin/` that calls the ones that
  # are in `bin/linux-x86_64/`
  # TODO: we should probably do the same for libraries
  postInstall = ''
    if [[ -d "$out/bin/${host_arch}" ]]; then
      for file in "$out/bin/${host_arch}/"*; do
        [[ -x "$file" ]] || continue

        makeWrapper "$file" "$out/bin/$(basename "$file")"
      done
    fi
    ''
    # When cross-compiling, EPICS actually compiles everything for the build
    # platform *and* for the host platform. We don't need products for the
    # build platform, so we remove them.
    #
    # TODO: find a solution upstream so that we don't waste time compiling for
    # the build platform.
    + (optionalString (stdenv.buildPlatform != stdenv.hostPlatform)
      ''
        rm -rf $out/{bin,lib}/${build_arch}
      '')
    + postInstall;

  doCheck = attrs.doCheck or true;
  checkTarget = "runtests";
})
