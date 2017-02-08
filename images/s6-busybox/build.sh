#
# build config
#
PACKAGES="sys-apps/busybox"

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build()
{
    update_use 'sys-apps/busybox' '+make-symlinks +static'
    # this runs in the builder, but as one of the last build steps the builder's /etc/passwd is copied to the custom root
    useradd busybox
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build()
{
    # log dir, root home dir
    mkdir -p $EMERGE_ROOT/var/log $EMERGE_ROOT/root
    # busybox crond setup
    mkdir -p $EMERGE_ROOT/var/spool/cron/crontabs
    chmod 0600 $EMERGE_ROOT/var/spool/cron/crontabs
    # eselect now uses a hard coded readlink path :/
    ln -sr $EMERGE_ROOT/bin/readlink $EMERGE_ROOT/usr/bin/readlink

    # S6 stuff
    # I don't want to do this in the Dockerfile.template
    mkdir $EMERGE_ROOT/service
    # copy busybox /etc which will have busybox service definition in /etc/service to $EMERGE_ROOT
    cp -a /config/etc $EMERGE_ROOT/
    # ensure busybox service's run script is executable
    chmod +x $(find $EMERGE_ROOT/etc/service -name run)
    # set up busybox service's finish script
    ln -s /etc/s6_finish_default $EMERGE_ROOT/etc/service/busybox/finish
    # enable service by adding it to the scan directory
    ln -s /etc/service/busybox $EMERGE_ROOT/service
}
