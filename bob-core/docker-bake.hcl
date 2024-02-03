variable "BASE_IMAGE" {
}

variable "IMAGE" {
  default = "kubler/bob-core"
}

variable "TAG" {
  default = "latest"
}

variable "MAINTAINER" {
  default = "berney"
}

# If default is `null`, it lets ARG default in Dockerfile be used
variable "DEF_CHOST" {
  default = null
  # glibc
  #default = "x86_64-pc-linux-gnu"
  # musl
  #default = "x86_64-gentoo-linux-musl"
}

variable "DEF_CFLAGS" {
  default = null
}
variable "DEF_CXXFLAGS" {
  default = null
}

# Only used for cross compiling
variable "DEF_BUILDER_CHOST" {
  default = null
}
variable "DEF_BUILDER_CFLAGS" {
  default = null
}
variable "DEF_BUILDER_CXXFLAGS" {
  default = null
}


group "default" {
  targets = [ "core" ]
}


target "core" {
  tags = [ "${IMAGE}:${TAG}" ]
  labels = {
    maintainer = "${MAINTAINER}"
  }
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    DEF_CHOST = "${DEF_CHOST}"
    DEF_CFLAGS = "${DEF_CFLAGS}"
    DEF_CXXFLAGS = "${DEF_CXXFLAGS}"
    DEF_BUILDER_CHOST = "${DEF_BUILDER_CHOST}"
    DEF_BUILDER_CFLAGS = "${DEF_BUILDER_CFLAGS}"
    DEF_BUILDER_CXXFLAGS = "${DEF_BUILDER_CXXFLAGS}"
  }
}
