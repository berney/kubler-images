#
# build config
#
_packages="sys-apps/s6"

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build()
{
    # Add our custom overlay
    add_overlay berne https://github.com/berney/gentoo-overlay.git

    update_use '+static-libs' '+minimal' '+static'
    #update_keywords 'dev-lang/execline' '+~amd64'
    #update_keywords 'dev-libs/skalibs' '+~amd64'
    #update_keywords 'sys-apps/s6' '+~amd64'
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build()
{
    ## s6-* are dynamically linked to Musl's libc so copy needed libraries and symlinks
    ## - This is better than add sys-libs/musl to PACKAGES as that will install unneeded headers, and .o files etc
    ## - lib/ld-musl-x86_64.so.1 -> /usr/lib/libc.so
    #mkdir -p "${_EMERGE_ROOT}/lib"
    #mkdir -p "${_EMERGE_ROOT}/usr/lib"
    #ln -s /usr/lib/libc.so "${_EMERGE_ROOT}/lib/ld-musl-x86_64.so.1"
    #cp -a /usr/lib/libc.so "${_EMERGE_ROOT}/usr/lib/libc.so"

    # Remove cruft - there's usr/lib/skalibs/*.lib and empty directories
    rm -rf "${_EMERGE_ROOT}/usr"

    # s6 folders
    mkdir -p "${_EMERGE_ROOT}/etc/service/.s6-svscan" "${_EMERGE_ROOT}/service"

    # This was from the Dockerfile.template
    # I'm planning on using musl as much as possible, ldconfig is glibc specific
    #ldconfig

    # I don't want to do this in the Dockerfile.template
    cp -a /config/etc "${_EMERGE_ROOT}/"
    # it should already be +x but this won't hurt
    chmod +x "${_EMERGE_ROOT}/etc/s6_finish_default"
    # I created this in the source already
    #ln -s /etc/s6_finish_default /etc/service/.s6-svscan/finish

    # We can do this step
    ln -s /etc/service/.s6-svscan "${_EMERGE_ROOT}/service"
}
