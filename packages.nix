{
  pkgs ? import <nixpkgs> { },
  maintainers ? import <nixpkgs> { }.lib.maintainers,
}:
rec {
  docker-flake-metadata = pkgs.callPackage ./pkgs/docker-flake-metadata { };
  gha-docker-flake-metadata = pkgs.callPackage ./pkgs/gha-docker-flake-metadata {
    inherit docker-flake-metadata;
  };

  docker-flake-metadata-image = pkgs.callPackage ./containers/docker-flake-metadata {
    inherit gha-docker-flake-metadata;
    inherit docker-flake-metadata;
  };

  default = docker-flake-metadata-image;
}
