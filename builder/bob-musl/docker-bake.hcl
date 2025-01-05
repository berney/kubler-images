## Usage:
#
# Show what it will do:
#
#   `docker buildx bake --print`

# NOTE: Interpolation needs `${FOO}` syntax
#       `$FOO` will be a litteral `$FOO`

## Variables
#
# Variables can be overridden by setting envvar
# - e.g. `TAG=buildx docker buildx bake --print`
#
# Or by using a `envs.hcl` file
#
# ```hcl
# SNAPSHOT="portage-20230425.tar.xz"
# BASE_IMAGE="gentoo/portage:20230425"
# ```
#
variable "BASE_TAG" {
  default = "latest"
}
variable "BASE_IMAGE" {
  default = "ghcr.io/berney/kubler-images/bob-musl-core:${BASE_TAG}"
}


## Groups
#
# Group of targets to build

# This is what is built by default when no arguments are supplied
group "default" {
  targets = [
    "bob-musl-builder",
    "bob-musl"
  ]
}

# This one has solid `/distfiles/` and `/packages/` directories
# They aren't using `RUN --mount` to make them bind/cache
# This is necessary so we can extract files back to host for caching
target "bob-musl-builder" {
  dockerfile = "Dockerfile.builder"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
  }
}

# This one has `RUN --mount` to cache mount `/distfiles/` and `/packages/` directories
# They are ephemeral, writes are discarded
# The BuildKit Cache means this target will build quickly since its effectively the same as the other target
target "bob-musl" {
  dockerfile = "Dockerfile.berney"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
  }
}
