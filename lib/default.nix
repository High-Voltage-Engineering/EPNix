# TODO: document every function
{
  inputs,
  lib,
  ...
} @ args:
with lib; let
  docParams = {
    outputAttrPath = ["epnix" "outputs"];
    optionsAttrPath = ["epnix" "doc"];
  };

  self = {
    formats = import ./formats.nix args;
    licenses = import ./licenses.nix args;
    maintainers = import ./maintainers/maintainer-list.nix;
    types = import ./types.nix args;

    evalEpnixModules = {
      nixpkgsConfig,
      epnixConfig,
    }: let
      nixpkgsConfigWithDefaults =
        {
          crossSystem = null;
          config = {};
        }
        // nixpkgsConfig;
      eval = evalModules {
        modules =
          [
            ({config, ...}: {
              config._module.args = let
                finalPkgs = import inputs.nixpkgs {
                  inherit (nixpkgsConfigWithDefaults) system crossSystem config;
                  overlays =
                    [
                      inputs.self.overlay
                      inputs.bash-lib.overlay
                    ]
                    ++ config.nixpkgs.overlays;
                };
              in {
                inherit (inputs) devshell;
                pkgs = finalPkgs;
              };
            })

            epnixConfig
            (inputs.nix-module-doc.lib.modules.doc-options-md docParams)
            (inputs.nix-module-doc.lib.modules.manpage docParams)
            (inputs.nix-module-doc.lib.modules.mdbook docParams)
          ]
          ++ import ../modules/module-list.nix;

        specialArgs = {epnixLib = self;};
      };

      # From Robotnix
      # From nixpkgs/nixos/modules/system/activation/top-level.nix
      failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) eval.config.assertions);

      config =
        if failedAssertions != []
        then throw "\nFailed assertions:\n${lib.concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
        else lib.showWarnings eval.config.warnings eval.config;
    in {
      inherit (eval) pkgs options;
      inherit config;

      inherit (config.epnix) outputs;
    };

    mkEpnixBuild = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.build;

    mkEpnixDevShell = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.devShell;

    mkEpnixManPage = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.manpage;
    mkEpnixMdBook = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.mdbook;

    # Like lib.getName, but also supports paths
    getName = thing:
      if builtins.isPath thing
      then baseNameOf thing
      else lib.getName thing;

    toEpicsArch = system: let
      inherit (system) parsed;

      kernel =
        {
          darwin = "darwin";
          macos = "darwin";

          freebsd = "freebsd";
          # TODO: is this correct?
          netbsd = "freebsd";
          openbsd = "freebsd";

          ios = "ios";

          linux = "linux";

          solaris = "solaris";

          win32 =
            if parsed.abi.name == "cygnus"
            then "cygwin"
            else "win32";
          windows =
            if parsed.abi.name == "cygnus"
            then "cygwin"
            else if arch == "x86"
            then "win32"
            else if arch == "x64"
            then "windows"
            else (throw "Unsupported architecture for windows: ${arch}");
        }
        .${parsed.kernel.name}
        or (throw "Unsupported kernel type: ${parsed.kernel.name}");

      arch =
        {
          x86_64 =
            if parsed.kernel.name == "windows"
            then "x64"
            else "x86_64";

          aarch64 = "aarch64";
          # TODO: is this correct? EPICS' CONFIG_SITE files don't seem to
          # differenciate between i386, i486, i586, and i686
          i686 = "x86";

          powerpc = "ppc";
          powerpc64 = "ppc64";

          sparc = "sparc";
        }
        .${parsed.cpu.name}
        or (throw "Unsupported architecture: ${parsed.cpu.name}");
    in "${kernel}-${arch}";

    resolveInput = {inputs} @ available: input:
      if isDerivation input
      then input
      else if hasPrefix "/" input
      then input
      else let
        path = splitString "." input;
      in
        {pname = last path;} // getAttrFromPath path available;
  };
in
  self
