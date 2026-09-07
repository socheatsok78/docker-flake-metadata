## About
GitHub Action to extract metadata from Nix Flakes for Docker Buildx Bake

## Usage

You can use `nix run github:socheatsok78/docker-flake-metadata` to invoke `docker-flake-metadata` or as a **GitHub Action**.

It will evaluate `flake.nix` and generate a **Docker Buildx Bake**'s `targets` for each packages.
```nix
# flake.nix
# syntax=socheatsok78/nixfile-frontend:experimental
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: {
      hello = pkgs.hello;

      default = inputs.self.packages.${system}.hello;
    }) inputs.nixpkgs.legacyPackages;
  };
}
```

```jsonc
// docker-flake-metadata.json
{
  "target": {
    "default-flake-metadata": {
      "description": "hello-2.12.3",
      "context": ".",
      "dockerfile": "flake.nix",
      "tags": [
        "default:2.12.3"
      ],
      "target": "default"
    },
    "hello-flake-metadata": {
      "description": "hello-2.12.3",
      "context": ".",
      "dockerfile": "flake.nix",
      "tags": [
        "hello:2.12.3"
      ],
      "target": "hello"
    }
  }
}
```

**GitHub Action**:

```yaml
jobs:
  # ...

  build:
    # ...
    steps:

      - name: Docker Nix Flake Metadata
        id: flake-meta
        uses: socheatsok78/docker-flake-metadata
        with:
          images: |
            docker.io/fakerepo
            ghcr.io/fakerepo

      - name: Build and push
        uses: docker/bake-action@v7
        with:
          files: |
            cwd://${{ steps.flake-meta.outputs.bake-file }}
```

