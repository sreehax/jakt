{
  description = "The Jakt Programming Language";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    gitignore = {
      url = github:hercules-ci/gitignore.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gitignore }: let
    forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    inherit (gitignore.lib) gitignoreSource;
  in {
    overlays.default = (final: prev:
      let
        buildInputs = with prev; [
          clang_16
          python3
        ];
        nativeBuildInputs = with prev; [
          pkg-config
          cmake
          ninja
       ];
      in rec {
        jakt = final.callPackage ./jakt.nix {
          inherit gitignoreSource;
          inherit buildInputs nativeBuildInputs;
        };
        jakt-unwrapped = jakt.unwrapped;
      }
    );

    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        jakt = pkgs.jakt;
        default = jakt;
      in rec {
        inherit default jakt;
      }
    );
    devShells = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          inherit (self.packages.${system}.default) buildInputs nativeBuildInputs;
        };
      }
    );
  };
}
