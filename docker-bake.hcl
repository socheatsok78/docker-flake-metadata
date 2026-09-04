variable "GITHUB_REPOSITORY_OWNER" {
    default = "socheatsok78"
}
variable "GITHUB_REPOSITORY" {
    default = "${GITHUB_REPOSITORY_OWNER}/docker-flake-metadata"
}
target "default" {
    dockerfile = "flake.nix"
    platforms = [
        "linux/amd64",
        "linux/arm64",
    ]
    tags = [
        "ghcr.io/${GITHUB_REPOSITORY}:latest",
    ]
}
