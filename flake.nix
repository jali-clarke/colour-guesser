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
        f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});

      mkHaskell = pkgs: pkgs.haskell.packages.ghc984.extend inputs.genetic.overlays.haskell;
    in
    {
      formatter = eachSystem (
        pkgs:
        (inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs.nixfmt.enable = true;
          programs.ormolu.enable = true;
          programs.yamlfmt.enable = true;
        }).config.build.wrapper
      );

      packages = eachSystem (pkgs: {
        default = (mkHaskell pkgs).callCabal2nix "colour-guesser" (pkgs.lib.fileset.toSource {
          root = ./.;
          fileset = pkgs.lib.fileset.unions [
            ./app
            ./src
            ./test
            ./package.yaml
          ];
        }) { };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          name = "haskell";

          packages =
            let
              ghc = (mkHaskell pkgs).ghcWithPackages (p: [
                p.hspec
                p.hspec-expectations
                p.genetic
                p.MonadRandom
                p.optparse-applicative
                p.QuickCheck
                p.threepenny-gui
                p.vector
              ]);

              cabal-install = pkgs.writeShellScriptBin "cabal" ''
                ${pkgs.hpack}/bin/hpack --silent
                exec ${pkgs.cabal-install}/bin/cabal --active-repositories=:none "$@"
              '';
            in
            [
              cabal-install
              ghc
              pkgs.hpack
            ];
        };
      });
    };
}
