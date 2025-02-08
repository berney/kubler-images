# syntax=docker/dockerfile:1
# The syntax line needs to be the first line

## Global Build ARGs
ARG AZ_CLI_VERSION=latest

FROM hashicorp/terraform AS terraform

FROM alpine AS gh-downloader
ARG GH_CLI_VERSION=2.66.1
ADD https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.tar.gz /gh-cli/
WORKDIR /gh-cli/
RUN <<-EOF
    ls -la
    tar xvf /gh-cli/gh_${GH_CLI_VERSION}_linux_amd64.tar.gz gh_${GH_CLI_VERSION}_linux_amd64/bin/gh
    mv gh_${GH_CLI_VERSION}_linux_amd64/bin/gh /usr/local/bin/
EOF

FROM mcr.microsoft.com/azure-cli:${AZ_CLI_VERSION}
COPY --link --from=terraform /bin/terraform /usr/local/bin/
COPY --link --from=gh-downloader /usr/local/bin/gh /usr/local/bin/
