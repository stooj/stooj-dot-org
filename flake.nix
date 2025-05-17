{
  description = "Development shell for norgolith blog";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    norgolith.url = "github:NTBBloodbath/norgolith";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      norgolith,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lith = norgolith.packages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            lith.default
          ];
        };
      }
    );
}
