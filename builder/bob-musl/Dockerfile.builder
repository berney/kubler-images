# syntax=docker/dockerfile:1
# The syntax line needs to be the first line

# There's two very similar Dockerfiles:
#   - Dockerfile.builder - has /distfiles and /packages
#   - Dockerfile.berney - clean, no /distfiles, no /packages
#
# The difference is berney one will produce an image without `/distifiles/` nor `/packages/` directories,
# because it's `RUN` had `--mount` with `type=cache`.
# This is intended to be the final clean image.
#
# The builder one is built first, and the image will have `/distfiles/` and `/packages/`, because it doesn't have the mount cache.
# A container can be created from the builder iamge, and the `/packages/` binpkgs and `/distfiles/` copied out to the localhost.
# These binpkgs can then be re-used in future builds.
# Because the two Dockerfiles are near identifical, after building the builder one, the berney one will use the BuildKit cache from the builder.
#
# After extracting the binpkgs, future builds will use them, e.g. when building a newer release, any packages that are unchanged between releases won't need to be recompiled as the binary packages can be installed.
# Because stages are being used, these named contexts can be overriden to copy files in from outside of the local build context, e.g. from the GHA cache.

# Global Args - these need to come before the first FROM
ARG BASE_IMAGE=berney/bob-musl-core:20240115

# This stage (named-context) can be overriden
FROM scratch AS distfiles
COPY --link /distfiles /

# This stage (named-context) can be overriden
FROM scratch AS packages
COPY --link /packages /

FROM ${BASE_IMAGE}
LABEL maintainer="Berne Campbell <berne.campbell@gmail.com>"
COPY --link --from=distfiles / /distfiles/
COPY --link --from=packages / /packages/
#COPY PACKAGES.md /config/
COPY --link build.sh /config/
#RUN <<-EOF
#RUN --mount=type=bind,target=/distfiles,from=distfiles,rw --mount=type=bind,target=/packages,from=packages,rw <<-EOF
#RUN --mount=type=cache,target=/distfiles,from=distfiles --mount=type=cache,target=/packages,from=packages <<-EOF
#RUN --mount=type=cache,target=/distfiles --mount=type=cache,target=/packages <<-EOF
RUN <<-EOF
  env | grep -E '^((BOB|DEF)_|PKGDIR)'
  ls -lF /
  ls -lF /config
  ls -ltraF /distfiles | tail || true
  ls -ltraF /packages | tail || true
  BOB_CURRENT_TARGET=berney/bob-musl kubler-build-root
  ls -ltraF /distfiles | tail || true
  ls -ltraF /packages | tail || true
EOF

CMD ["/bin/bash"]

LABEL kubler.build.timestamp=20240117105721
