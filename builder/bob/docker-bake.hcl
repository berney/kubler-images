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
# BASE_IMAGE="gentoo/porage:20230425"
# ```
#
variable "BASE_TAG" {
  default = "latest"
}
variable "BASE_IMAGE" {
  default = "ghcr.io/berney/kubler-images/bob-core:${BASE_TAG}"
}



## Groups
#
# Group of targets to build

# This is what is built by default when no arguments are supplied
group "default" {
  targets = [ "bob" ]
}

target "bob" {
  dockerfile = "Dockerfile.berney"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
  }
}
