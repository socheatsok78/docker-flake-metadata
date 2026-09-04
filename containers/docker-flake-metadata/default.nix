{
  lib,
  stdenvNoCC,
  dockerTools,
  docker-flake-metadata,
  gha-docker-flake-metadata,
}:
let
  nixBaseSystem = dockerTools.pullImage {
    imageName = "nixos/nix";
    imageDigest = "sha256:7a007c766426c1877758ddc5cb87a965ac131fc78c582ce0083d922d51ae945c";
    hash =
      {
        x86_64-linux = "sha256-Gqpj/Vf/Kjv3C5WQZZ00oLz0T1/hc0II1YoG33Fd0aE=";
        aarch64-linux = "sha256-k2sgOXZXurc/kkPQVG0WZ2lwBslj/jowTDtF9tS3xCs=";
      }
      .${stdenvNoCC.hostPlatform.system}
        or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  };
in
dockerTools.buildLayeredImage {
  name = "docker-flake-metadata";
  tag = "latest";
  fromImage = nixBaseSystem;
  contents = [
    gha-docker-flake-metadata
    docker-flake-metadata
  ];
  config = {
    Entrypoint = [ (lib.getExe gha-docker-flake-metadata) ];
  };
}
