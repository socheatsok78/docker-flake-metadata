#!/usr/bin/env nix
#! nix shell --file ``<nixpkgs>`` jq docker-buildx --command bash
set -uo pipefail
SCRIPTSRC=$(dirname "$(realpath "$0")")
DOCKER_FLAKE_METADATA_FILE="${SCRIPTSRC}/docker-flake-metadata.hcl"

export DOCKER_FLAKE_METADATA_SRC="${1:-${DOCKER_FLAKE_METADATA_SRC:-}}"
export DOCKER_FLAKE_METADATA_IMAGES="${DOCKER_FLAKE_METADATA_IMAGES:-}"

function flake-to-bake-targets() {
	jq -r '.packages[] | keys | flatten[]' | sort | uniq | while read -r pkg; do
		pkgname=$(nix eval --quiet --raw "${DOCKER_FLAKE_METADATA_SRC}#$pkg.name" 2>/dev/null)
		pkgversion=$(nix eval --quiet --raw "${DOCKER_FLAKE_METADATA_SRC}#$pkg.version" 2>/dev/null)
		pkgtag=$(nix eval --quiet --raw "${DOCKER_FLAKE_METADATA_SRC}#$pkg.imageTag" 2>/dev/null)
		if [ -z "$pkgtag" ]; then
			pkgtag="$pkgversion"
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
	docker-buildx bake -f "${DOCKER_FLAKE_METADATA_FILE}" -f - '*' --print | jq -r 'del(.group)'
}

nix flake show "${DOCKER_FLAKE_METADATA_SRC}" --json 2>/dev/null | flake-to-bake-targets | docker-flake-metadata
