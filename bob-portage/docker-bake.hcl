## Usage:
#
# Show what it will do:
#
#     `docker buildx bake --print` -- default
#     `docker buildx bake --print kubler` -- based off original
#     `docker buildx bake --print gentoo` -- based off `gentoo/portage`
#     `docker buildx bake --print vendored` -- based off local `gentoo/portage` dockerfile
#     `docker buildx bake --print gentoo-kubler` -- include intermediate image in output
#     `docker buildx bake --print vendored-kubler` -- include intermediate image in output
#
# Build `kubler-gentoo/portage` based off `kubler-gentoo/portage:gentoo-latest`
# This is a decomposed version of how kubler originally did it, it copies the portage snapshot from the host.
#
#     `docker buildx bake --load kubler`
#
# The above doesn't load the intermediate `kubler-gentoo:gentoo-latest` (unpatched) image.
# It builds and caches it but doesn't load it into the local registry. If you want it loaded as well, use:
#
#     `docker buildx bake --load gentoo-kubler`
#
# Build `kubler-gentoo/portage` image off based off upstream official `gentoo/portage` image
#
#     `docker buildx bake --load gentoo`
#
# Build `kubler-gentoo/portage` image off based off local vendored version of upstream official `gentoo/portage` image
# This first builds the equivalent of upstream's `gentoo/portage`, using our vendored copy of their dockerfile.
# It downloads the portage snapshot inside the container.
#
#     `docker buildx bake --print vendored`
#
# Same as above but also load the intermediate gentoo (unpatched) portage image
#
#     `docker buildx bake --print vendored-kubler`
#
# Overriding the snapshot used
#
#     `SNAPSHOT=portage-20230425.tar.xz docker buildx bake --print kubler`
#     `SNAPSHOT=portage-20230425.tar.xz docker buildx bake --print vendored`
#
# Use portage snapshot outside of normal build context
#
#     `SNAPSHOT=portage-20230423.tar.xz docker buildx bake kubler --load --set gentoo-portage.contexts.portage=$HOME/.kubler/downloads`


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
variable "BASE_IMAGE" {
  # Use upstream offical gentoo/portage image
  default = "gentoo/portage"
}

variable "TAG" {
  default = "latest"
}

variable "gentoo-tag" {
  default = "gentoo-${TAG}"
}

variable "vendored-tag" {
  default = "vendored-${TAG}"
}

variable "MAINTAINER" {
  default = "berney"
}

variable "SNAPSHOT" {
  default = "portage-latest.tar.xz"
}

variable "DIST" {
  default = "https://ftp-osl.osuosl.org/pub/gentoo/snapshots"
}

variable "SIGNING_KEY" {
  default = "0xEC590EEAC9189250"
}


## Groups
#
# Group of targets to build

# This is what is built by default when no arguments are supplied
group "default" {
  # BASE_IMAGE="gentoo/portage"
  targets = [ "gentoo" ]
}

# Base off tarball (e.g. original kubler style) copied from host
# - This is decomposed version of the original kubler style
# - portage snapshot is copied from the host
# - patched applied
group "gentoo-kubler" {
  targets = [ "gentoo-portage", "kubler" ]
}

# Base off upstream `gentoo/portage`, with kubler patches applied
group "gentoo" {
  # BASE_IMAGE="gentoo/portage"
  targets = [ "kubler-portage" ]

}

# Base off vendored copy of upstream's `gentoo/portage` dockerfile
# - portage snapshot is downloaded inside container
# - patched applied
group "vendored-kubler" {
  # - kubler patches applied
  # BASE_IMAGE=target.vendored-portage.tags
  targets = [ "vendored-portage", "vendored" ]
}


# Uses gentoo portage tarball file
# - Vanilla, doesn't have any patches applied
# - This is alternative to using upstream `gentoo/portage` base image
# - This is equivalent of kubler's original behaviour before decomposing it into this
target "gentoo-portage" {
  dockerfile = "Dockerfile.download"
  tags = ["kubler-gentoo/portage:${gentoo-tag}"]
  args = {
    SNAPSHOT = "${SNAPSHOT}"
  }
  labels = {
    maintainer = "${MAINTAINER}"
  }
}


# This uses a vendored copy of `gentoo/gentoo-docker-images` portage.Dockerfile
# - This can be used as the base image
# - Difference between this an gentoo-portage target is this one downloads the portage snapshot tarball inside the container
#   whereas the gentoo-portage target uses a portage snapshot tarball file in the build context
target "vendored-portage" {
  dockerfile = "portage.Dockerfile"
  tags = ["kubler-gentoo/portage:${vendored-tag}"]
  args = {
    SNAPSHOT = "${SNAPSHOT}"
    DIST = "${DIST}"
    SIGNING_KEY = "${SIGNING_KEY}"
  }
  labels = {
    maintainer = "${MAINTAINER}"
  }
}


# Applies Kubler patches to portage
# - Uses other targets as its base image
# - default base image is upstream official `gentoo/portage` image
target "kubler-portage" {
  dockerfile = "Dockerfile.kubler"
  tags = ["kubler-gentoo/portage:${TAG}"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
  }
  labels = {
    maintainer = "${MAINTAINER}"
  }
}

# Applies Kubler patches to portage
# - base image is original kubler-style where portage snapshot copied from host
target "kubler" {
  inherits = ["kubler-portage"]
  contexts = {
    gentoo-portage = "target:gentoo-portage"
  }
  args = {
    # This will try to pull whatever `target.gentoo-portage.tags[0]` resolves to, e.g. `kubler-gentoo/portage:gentoo-latest`, rather than use the image we just baked
    #BASE_IMAGE = target.gentoo-portage.tags[0]

    BASE_IMAGE = "gentoo-portage"
  }
}

# Applies Kubler patches to portage
# - base image is vendored copy `gentoo/portage` dockerfile where portage snapshot is downloaded inside container
target "vendored" {
  inherits = ["kubler-portage"]
  contexts = {
    vendored-portage = "target:vendored-portage"
  }
  args = {
    #BASE_IMAGE = target.vendored-portage.tags[0]
    BASE_IMAGE = "vendored-portage"
  }
}
