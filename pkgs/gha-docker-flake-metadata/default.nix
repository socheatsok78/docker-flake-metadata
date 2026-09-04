{
  lib,
  writeShellApplication,
  jq,
  docker-flake-metadata,
}:
writeShellApplication {
  name = "gha-docker-flake-metadata";
  runtimeInputs = [
    jq
    docker-flake-metadata
  ];
  text = ''
    ME=docker-flake-metadata

    github.setoutput() {
        echo "$1=$2" >> "''${GITHUB_OUTPUT:-''${RUNNER_TEMP}/github-output}"
    }
    nix.setopt() {
        echo "$1 = $2" >> /etc/nix/nix.conf
    }
    log() {
        printf '## [%s] %s\n' "$ME" "$*" >&2
    }

    if [[ -n "''${GITHUB_TOKEN}" ]]; then
        log "Setting up GitHub token for authentication..."
        nix.setopt "access-tokens" "github.com=''${GITHUB_TOKEN}"
    fi

    RUNNER_TEMP=''${RUNNER_TEMP:-/tmp}
    DOCKER_FLAKE_METADATA_KEY=$(mktemp --dry-run "docker-flake-metadata.XXXXXX")
    DOCKER_FLAKE_METADATA_TEMP="''${RUNNER_TEMP}/''${DOCKER_FLAKE_METADATA_KEY}"
    DOCKER_FLAKE_METADATA_FILE="''${DOCKER_FLAKE_METADATA_TEMP}/docker-flake-metadata.json"
    mkdir -p "''${DOCKER_FLAKE_METADATA_TEMP}"

    # Execute the docker-flake-metadata and output to the mounted RUNNER_TEMP directory for GitHub Actions to pick up the output file.
    ${lib.getExe docker-flake-metadata} "$@" | tee "''${DOCKER_FLAKE_METADATA_FILE}"
    chmod 0644 "''${DOCKER_FLAKE_METADATA_FILE}"

    # Set the output variable for GitHub Actions to point to the generated bake file using the runner context to get the temp directory.
    RUNNER_CONTEXT=''${INPUT_RUNNER:-'{"temp": "/tmp"}'}
    RUNNER_TEMP=$(echo "''${RUNNER_CONTEXT}" | jq -r '.temp')
    DOCKER_FLAKE_METADATA_TEMP="''${RUNNER_TEMP}/''${DOCKER_FLAKE_METADATA_KEY}"
    DOCKER_FLAKE_METADATA_FILE="''${DOCKER_FLAKE_METADATA_TEMP}/docker-flake-metadata.json"
    log "Setting output variable for GitHub Actions"
    log "- bake-file=''${DOCKER_FLAKE_METADATA_FILE}"
    github.setoutput "bake-file" "''${DOCKER_FLAKE_METADATA_FILE}"
  '';
  meta = {
    mainProgram = "gha-docker-flake-metadata";
  };
}
