ARG ORAS_VERSION=v1.1.0

FROM berne/goss AS goss

FROM ghcr.io/oras-project/oras:${ORAS_VERSION} as oras

FROM alpine
COPY --from=goss /bin/goss /usr/local/bin/
COPY --from=oras /bin/oras /usr/local/bin/
COPY dgoss /usr/local/bin/
RUN <<-EOF
    set -eux
    pwd
    apk add --no-cache \
        bash \
        curl \
        docker-cli \
        docker-cli-buildx \
        git \
        gpg \
        jq \
        ncurses \
        wget
    type goss
    goss --version
    type dgoss
    dgoss || true
    oras version

    # Install Kubler
    git clone https://github.com/berney/kubler.git
    cd kubler || exit 1
    git checkout f-experiment-buildx-bake
    git describe --all --long --dirty
    ls -l bin
    ln -s "$(pwd)/bin/kubler" /usr/local/bin/kubler
    type kubler
    # kubler cares about what directory it is in
    cd .. || exit 1
    # kubler uses `tput`, which gets an error if `TERM` isn't set
    export TERM=dumb
    kubler --help
    ls -la ~/.kubler || true
    ls -la ~/.kubler/namespaces || true
    ls -la ~/.kubler/namespaces/kubler || true
    # Kubler gets upset if not in a valid namespace directory
    cd ~/.kubler || exit 1
    kubler update || true
    cd / || exit 1
    ls -la ~/.kubler || true
    ls -la ~/.kubler/namespaces || true
    ls -la ~/.kubler/namespaces/kubler || true
    grep '^STAGE3_DATE=' ~/.kubler/namespaces/kubler/builder/bob/build.conf
    grep '^STAGE3_DATE=' ~/.kubler/namespaces/kubler/builder/bob-musl/build.conf
    bob=$(sed -n "s/^STAGE3_DATE='\(202[34][01][0-9]\{3\}T[0-9]\{6\}Z\)'$/\\1/p" ~/.kubler/namespaces/kubler/builder/bob/build.conf)
    bob_musl=$(sed -n "s/^STAGE3_DATE='\(202[34][01][0-9]\{3\}T[0-9]\{6\}Z\)'$/\\1/p" ~/.kubler/namespaces/kubler/builder/bob-musl/build.conf)
    if [ "$bob" != "$bob_musl" ]; then
        echo "WARNING: bob and bob-musl have different STAGE3_DATE"
    fi
    BOB_STAGE3_DATE="$bob"
    BOB_MUSL_STAGE3_DATE="$bob_musl"
    export BOB_STAGE3_DATE
    export BOB_MUSL_STAGE3_DATE
    ls -l kubler/cmd
EOF
COPY kubler/cmd kubler/cmd
RUN <<-EOF
    ls -l kubler/cmd
    export TERM=dumb
    cd ~/.kubler || exit 1
    kubler portage
    PORTAGE_DATE=$(kubler portage)
    export PORTAGE_DRATE
EOF
