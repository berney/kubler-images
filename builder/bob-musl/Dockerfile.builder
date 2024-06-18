ARG BASE_IMAGE=berney/bob-musl-core:20240115
FROM ${BASE_IMAGE}
LABEL maintainer="Berne Campbell <berne.campbell@gmail.com>"
#COPY PACKAGES.md /config/
COPY build.sh /config/
#RUN <<-EOF
#RUN --mount=type=bind,target=/distfiles,from=distfiles,rw --mount=type=bind,target=/packages,from=packages,rw <<-EOF
#RUN --mount=type=cache,target=/distfiles,from=distfiles --mount=type=cache,target=/packages,from=packages <<-EOF
#RUN --mount=type=cache,target=/distfiles --mount=type=cache,target=/packages <<-EOF
RUN <<-EOF
  env | grep -E '^((BOB|DEF)_|PKGDIR)'
  ls -l /config
  ls -ltra /distfiles | tail || true
  ls -ltra /packages | tail || true
  BOB_CURRENT_TARGET=berney/bob-musl kubler-build-root
  ls -ltra /distfiles | tail || true
  ls -ltra /packages | tail || true
EOF

CMD ["/bin/bash"]

LABEL kubler.build.timestamp=20240117105721
