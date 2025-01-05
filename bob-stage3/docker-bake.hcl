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
variable "MAINTAINER" {
  default = "berney"
}
variable "TAG" {
  default = "latest"
}
variable "STAGE3_FILE" {
}

variable "IMAGE" {
  default = "kubler-gentoo/stage3"
}

variable "BASE_TAG" {
  default = "latest"
}
variable "BASE_IMAGE" {
  default = "gentoo/stage3:${BASE_TAG}"
}

variable "PORTAGE" {
  default = "gentoo/portage"
}


## Groups
#
# Group of targets to build

# This is what is built by default when no arguments are supplied
group "default" {
  #targets = [ "stage3" ]
  targets = [ "gentoo-stage3" ]
}

group "kubler" {
  targets = [ "stage3" ]
}


target "tarball" {
  # Can only supply additional contexts
  # - Which will upload whole directory
  #contexts = {
  #}
  args = {
    stage3_file = "${STAGE3_FILE}"
  }
}
target "stage3" {
  tags = ["${IMAGE}:${TAG}"]
  contexts = {
    tarball = "target:tarball"
  }
  args = {
    stage3_file = "${STAGE3_FILE}"
  }
  labels = {
    maintainer = "${MAINTAINER}"
  }
}

target "gentoo-stage3" {
  dockerfile = "Dockerfile.gentoo"
  tags = ["${IMAGE}:${TAG}"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    PORTAGE = "${PORTAGE}"
  }
  labels = {
    maintainer = "${MAINTAINER}"
  }
}

