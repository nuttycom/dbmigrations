{
  description = "Relational database migrations modeled as a directed acyclic graph";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: let
    pkg-name = "dbmigrations";
    haskell-overlay = hfinal: hprev: {
      ${pkg-name} = hfinal.callCabal2nix pkg-name ./. {};
    };

    overlay = final: prev: {
      haskellPackages = prev.haskellPackages.extend haskell-overlay;
    };
  in
    {
      overlays = {
        default = overlay;
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [overlay];
        };

        hspkgs = pkgs.haskellPackages;
      in {
        packages = {
          ${pkg-name} = hspkgs.${pkg-name};
          default = self.packages.${system}.${pkg-name};
        };

        devShells = {
          default = hspkgs.shellFor {
            packages = _: [self.packages.${system}.${pkg-name}];
            buildInputs = [
              pkgs.cabal-install
              hspkgs.ormolu
            ];
            withHoogle = true;
            inputsFrom = builtins.attrValues self.packages.${system};
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
