{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    genetic = {
      url = "path:/home/jali-clarke/Repos/genetic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      eachSystem =
        f: inputs.nixpkgs.lib.genAttrs systems (system: f system inputs.nixpkgs.legacyPackages.${system});

      mkHaskell = pkgs: pkgs.haskell.packages.ghc984.extend inputs.genetic.overlays.haskell;
    in
    {
      formatter = eachSystem (
        _: pkgs:
        (inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs.nixfmt.enable = true;
          programs.ormolu.enable = true;
          programs.yamlfmt.enable = true;
        }).config.build.wrapper
      );

      packages = eachSystem (
        _: pkgs: {
          default = (mkHaskell pkgs).callCabal2nix "colour-guesser" (pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [
              ./app
              ./src
              ./test
              ./package.yaml
            ];
          }) { };
        }
      );

      devShells = eachSystem (
        system: pkgs: {
          default = (mkHaskell pkgs).shellFor {
            packages = _: [ self.packages.${system}.default ];

            nativeBuildInputs =
              let
                cabal-install = pkgs.writeShellScriptBin "cabal" ''
                  ${pkgs.hpack}/bin/hpack --silent
                  exec ${pkgs.cabal-install}/bin/cabal --active-repositories=:none "$@"
                '';
              in
              [
                cabal-install
                pkgs.hpack
              ];
          };
        }
      );
    };
}
