variable "GITHUB_REPOSITORY_OWNER" {
    default = "socheatsok78"
}
variable "GITHUB_REPOSITORY" {
    default = "${GITHUB_REPOSITORY_OWNER}/docker-flake-metadata"
}

target "docker-metadata-action" {}
target "github-metadata-action" {}

target "default" {
    dockerfile = "flake.nix"
    target = "docker-flake-metadata-image"
    inherits = [ 
        "docker-metadata-action",
        "github-metadata-action",
    ]
    platforms = [
        "linux/amd64",
        "linux/arm64",
    ]
    tags = [
        "ghcr.io/${GITHUB_REPOSITORY}:latest",
    ]
}
