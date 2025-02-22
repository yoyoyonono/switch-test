# This is an example flake.nix for a Switch project based on devkitA64.
# It will work on any devkitPro example with a Makefile out of the box.
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devkitNix.url = "github:bandithedoge/devkitNix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devkitNix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        # devkitNix provides an overlay with the toolchains
        overlays = [devkitNix.overlays.default];
      };
    in {

      devShells.default = pkgs.mkShell {
        # devkitNix packages also provide relevant tools you may want available
        # in your PATH.
        buildInputs = [pkgs.devkitNix.devkitA64];

        # Each package provides a shell hook that sets all necessary
        # environmental variables. This part is necessary, otherwise your build
        # system won't know where to find devkitPro. By setting these
        # variables we allow devkitPro's example Makefiles to work out of the box.
        inherit (pkgs.devkitNix.devkitA64) shellHook;
      };

      packages.default = pkgs.stdenv.mkDerivation {
        name = "devkitA64-example";
        src = ./.;

        # `TARGET` determines the name of the executable.
        makeFlags = ["TARGET=example"];
        # The shell hook is used in the build to point your build system to
        # devkitPro.
        preBuild = pkgs.devkitNix.devkitA64.shellHook;
        # This is a simple Switch app example that only builds a single
        # executable. If your project outputs multiple files, make `$out` a
        # directory and copy everything there.
        installPhase = ''
          cp example.nro $out
        '';
      };

    });
}
