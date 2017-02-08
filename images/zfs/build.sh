#PACKAGES="app-misc/figlet"
#PACKAGES="app-misc/figlet sys-libs/musl"
# Don't set packages so that baselayout won't be installed
PACKAGES="sys-fs/zfs"

#
# this hook can be used to configure the build container itself, install packages, etc
#
configure_bob() {
	update_keywords 'sys-fs/zfs' '+~amd64'
	update_keywords 'sys-fs/zfs-kmod' '+~amd64'
	update_keywords 'sys-kernel/spl' '+~amd64'
	emerge sys-kernel/gentoo-sources
	ls -l /proc/config.gz || true
	ls -ld /usr/src/linux || true
	ls -l /usr/src/linux/.config || true
	zcat /proc/config.gz > /usr/src/linux/.config
	#emerge sys-kernel/spl
}

configure_rootfs_build() {
	:
}

finish_rootfs_build() {
	:
}
