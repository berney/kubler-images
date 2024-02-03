# syntax=docker/dockerfile:1
FROM scratch AS tarball
ARG stage3_file
COPY ${stage3_file} /

FROM busybox:latest AS untar
ARG stage3_file
WORKDIR /stage3
RUN --mount=type=bind,target=/tarball,from=tarball <<-EOF
    #!/bin/sh
    set -eux
    ls -l /tarball/
    tar xJf /tarball/$stage3_file
EOF

FROM scratch
COPY --from=untar /stage3 /
