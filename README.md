## About
GitHub Action to extract metadata from Nix Flakes for Docker Buildx Bake

## Usage

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
