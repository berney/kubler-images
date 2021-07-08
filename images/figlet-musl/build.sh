_packages="app-misc/figlet"

#
# this hook can be used to configure the build container itself, install packages, etc
#
configure_bob() {
	:
}

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build() {
	# this runs in the builder, but as one of the last build steps the builder's /etc/passwd is copied to the custom root
	useradd figlet
	# Create home directory in custom root
	# we don't need this for our purposes
	#mkdir -p $_EMERGE_ROOT/home/figlet

	set -u
	mkdir -p $_EMERGE_ROOT/lib
	mkdir -p $_EMERGE_ROOT/usr/lib

	set +u
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build() {
	echo "XXX original options $-"
	set -u
	# Figlet is dynamically linked to Musl's libc so copy needed libraries and symlinks
	# - This is better than add sys-libs/musl to PACKAGES as that will install unneeded headers, and .o files etc
	# - lib/ld-musl-x86_64.so.1 -> /usr/lib/libc.so
	ln -s /usr/lib/libc.so $_EMERGE_ROOT/lib/ld-musl-x86_64.so.1
	cp -a /usr/lib/libc.so $_EMERGE_ROOT/usr/lib/libc.so

	# figlist and showfig fonts are shell scripts needing /bin/sh, since we are building without a shell purge them too
	rm -f $_EMERGE_ROOT/usr/bin/{figlist,showfigfonts}
	# no USE flag for bash-completion so just rm it
	rm -rf $_EMERGE_ROOT/usr/share/bash-completion/
	# Not sure how to stop these
	rm -rf $_EMERGE_ROOT/var/lib/gentoo
	rm -rf $_EMERGE_ROOT/var
	# mostly coming from env-update, doesn't seem needed
	rm -rf $_EMERGE_ROOT/etc
	# to run as USER we need /etc/{passwd,group}
	mkdir -p $_EMERGE_ROOT/etc
	# handle bug in portage when using custom root, user/groups created during install are not created at the custom root but on the host
	cp -f /etc/{passwd,group} $_EMERGE_ROOT/etc
	set +u
	echo "XXX options $-"
}
