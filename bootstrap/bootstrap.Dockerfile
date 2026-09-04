FROM nixos/nix
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
RUN nix-env -iA nixpkgs.jq
RUN nix-env -iA nixpkgs.docker-buildx

ENV GITHUB_OUTPUT=/tmp/github_output
ENV RUNNER_TEMP=/tmp
ENV BUILDKIT_PROGRESS=plain
COPY --chmod=0755 rootfs/init /
COPY --chmod=0755 rootfs/docker-flake-metadata.sh /
COPY rootfs/docker-flake-metadata.hcl /
ENTRYPOINT [ "/init" ]
