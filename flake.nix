# syntax=socheatsok78/nixfile-frontend:experimental
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    maintainers = {
      url = "github:socheatsok78/maintainers.nix";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      maintainers,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./packages.nix {
          inherit maintainers;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      # nix fmt (experimental)
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
