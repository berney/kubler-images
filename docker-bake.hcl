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

## Groups
#
# Group of targets to build

# This is what is built by default when no arguments are supplied
group "default" {
  targets = [ "kubler" ]
}

target "kubler" {
}
