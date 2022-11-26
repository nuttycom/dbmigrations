{
  description = "Relational database migrations modeled as a directed acyclic graph";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkg-name = "dbmigrations";
        pkgs = import nixpkgs {
          inherit system;
        };

        haskell = pkgs.haskellPackages;

        haskell-overlay = final: prev: {
          ${pkg-name} = hspkgs.callCabal2nix pkg-name ./. {};
          # Add here any package overrides you may need
        };

        hspkgs = haskell.override {
          overrides = haskell-overlay;
        };
      in {
        packages = pkgs;

        defaultPackage = hspkgs.${pkg-name};

        devShell = hspkgs.shellFor {
          packages = p: [p.${pkg-name}];
          root = ./.;
          withHoogle = true;
          buildInputs = with hspkgs; [
            haskell-language-server
            cabal-install
          ];
        };
      });
}
