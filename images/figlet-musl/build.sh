#PACKAGES="app-misc/figlet"
#PACKAGES="app-misc/figlet sys-libs/musl"
# Don't set packages so that baselayout won't be installed
PACKAGES_M="app-misc/figlet"

#
# this hook can be used to configure the build container itself, install packages, etc
#
configure_bob() {
	# Setup portage so that all ebuilds will apply user patches
	cp /config/etc-portage-bashrc /etc/portage/bashrc
	chmod +x /etc/portage/bashrc

	# Add user patch from Alpine Linux aports to fix figlet C++ problems so that it will compile under musl
	mkdir -p /etc/portage/patches/app-misc/figlet/
	cp /config/*.patch /etc/portage/patches/app-misc/figlet/
}

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build() {
	# this runs in the builder, but as one of the last build steps the builder's /etc/passwd is copied to the custom root
	useradd figlet
	# Create home directory in custom root
	# we don't need this for our purposes
	#mkdir -p $EMERGE_ROOT/home/figlet

	# We don't set PACKAGES to avoid installing baselayout so install it now
	mkdir -p $EMERGE_ROOT/lib
	mkdir -p $EMERGE_ROOT/usr/lib
	"${EMERGE_BIN}" ${EMERGE_OPT} --binpkg-respect-use=y -v $PACKAGES_M
	# As we broke the normal builder chain, recreate the docs for the figlet-musl image
	init_docs "$PACKAGES_M"
	#update_use "$PACKAGES_M" "+musl"
	generate_doc_package_installed "$PACKAGES_M"
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build() {
	# Figlet is dynamically linked to Musl's libc so copy needed libraries and symlinks
	# - This is better than add sys-libs/musl to PACKAGES as that will install unneeded headers, and .o files etc
	# - lib/ld-musl-x86_64.so.1 -> /usr/lib/libc.so
	ln -s /usr/lib/libc.so $EMERGE_ROOT/lib/ld-musl-x86_64.so.1
	cp -a /usr/lib/libc.so $EMERGE_ROOT/usr/lib/libc.so

	# if we install packages build-root automatically installs baselayout
	#uninstall_package -vt sys-apps/baselayout

	# figlist and showfig fonts are shell scripts needing /bin/sh, since we are building without a shell purge them too
	rm -f $EMERGE_ROOT/usr/bin/{figlist,showfigfonts}
	# no USE flag for bash-completion so just rm it
	rm -rf $EMERGE_ROOT/usr/share/bash-completion/
	# Not sure how to stop these
	rm -rf $EMERGE_ROOT/var/lib/gentoo
	rm -rf $EMERGE_ROOT/var
	# mostly coming from env-update, doesn't seem needed
	rm -rf $EMERGE_ROOT/etc
	# to run as USER we need /etc/{passwd,group}
	mkdir -p $EMERGE_ROOT/etc
	# handle bug in portage when using custom root, user/groups created during install are not created at the custom root but on the host
	cp -f /etc/{passwd,group} $EMERGE_ROOT/etc
}
