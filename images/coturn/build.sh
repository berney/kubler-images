_packages="net-im/coturn"
#_timezone="${BOB_TIMEZONE:-UTC}"

:
configure_bob() {
    update_use 'sys-apps/util-linux' -su -logger
    #emerge -1 sys-libs/timezone-data
    # set timezone
    #echo "${_timezone}" > /etc/timezone
}

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build() {
    update_keywords 'net-im/coturn' '+~amd64'
    # add user and group turnserver for coturn
    useradd turnserver
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build() {
    # S6 stuff
    # I don't want to do this in the Dockerfile.template
    mkdir "${_EMERGE_ROOT}"/service
    # copy turnserver /etc which will have turnserver service definition in /etc/service to "${_EMERGE_ROOT}"
    cp -a /config/etc "${_EMERGE_ROOT}"/
    # ensure turnserver service's run script is executable
    chmod +x $(find "${_EMERGE_ROOT}"/etc/service -name run)
    # set up turnserver service's finish script
    ln -s /etc/s6_finish_default "${_EMERGE_ROOT}"/etc/service/turnserver/finish
    # enable service by adding it to the scan directory
    ln -s /etc/service/turnserver "${_EMERGE_ROOT}"/service
}
