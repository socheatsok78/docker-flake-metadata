{
  writeTextFile,
  writeShellApplication,
  jq,
  docker-buildx,
}:
let
  dockerFlakeMetadataHcl = writeTextFile {
    name = "docker-flake-metadata";
    destination = "/docker-flake-metadata.hcl";
    text = builtins.readFile ./docker-flake-metadata.hcl;
  };
in
writeShellApplication {
  name = "docker-flake-metadata";
  runtimeInputs = [
    jq
    docker-buildx
    dockerFlakeMetadataHcl
  ];
  bashOptions = [ ];
  text = ''
    export DOCKER_FLAKE_METADATA_SRC="''${1:-''${DOCKER_FLAKE_METADATA_SRC:-}}"
    export DOCKER_FLAKE_METADATA_IMAGES="''${DOCKER_FLAKE_METADATA_IMAGES:-}"
    DOCKER_FLAKE_METADATA_FILE="${dockerFlakeMetadataHcl}/docker-flake-metadata.hcl"

    function nix-experimental() {
        nix --extra-experimental-features "nix-command flakes" "$@"
    }

    function flake-to-bake-targets() {
        jq -r '.packages[] | keys | flatten[]' | sort | uniq | while read -r pkg; do
            pkgname=$(nix-experimental eval --quiet --raw "''${DOCKER_FLAKE_METADATA_SRC}#$pkg.name" 2>/dev/null)
            pkgversion=$(nix-experimental eval --quiet --raw "''${DOCKER_FLAKE_METADATA_SRC}#$pkg.version" 2>/dev/null)
            pkgtag=$(nix-experimental eval --quiet --raw "''${DOCKER_FLAKE_METADATA_SRC}#$pkg.imageTag" 2>/dev/null)
            if [ -z "$pkgtag" ]; then
                pkgtag="$pkgversion"
            fi
            if [ -z "$pkgtag" ]; then
                pkgtag="untagged"
            fi
            printf 'target "%s-flake-metadata" {\n' "$pkg"
            printf '    dockerfile = "flake.nix"\n'
            printf '    description = "%s"\n' "$pkgname"
            printf '    target = "%s"\n' "$pkg"
            printf '    labels = {\n'
            printf '        "nix.flake.metadata.source" = "%s"\n' "$DOCKER_FLAKE_METADATA_SRC"
            printf '        "nix.flake.metadata.target" = "%s"\n' "$pkg"
            printf '        "nix.flake.metadata.name" = "%s"\n' "$pkgname"
            printf '        "nix.flake.metadata.version" = "%s"\n' "$pkgtag"
            printf '    }\n'
            printf '    tags = tags("%s", "%s")\n' "$pkg" "$pkgtag"
            printf '}\n'
        done
    }

    function docker-flake-metadata() {
        docker-buildx bake -f "''${DOCKER_FLAKE_METADATA_FILE}" -f - '*' --print | jq -r 'del(.group)'
    }

    nix-experimental flake show "''${DOCKER_FLAKE_METADATA_SRC}" --json 2>/dev/null \
        | flake-to-bake-targets \
        | docker-flake-metadata
  '';
  meta = {
    mainProgram = "docker-flake-metadata";
  };
}
