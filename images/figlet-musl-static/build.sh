## This is an exercise in minimalism

#PACKAGES="app-misc/figlet"
#PACKAGES="app-misc/figlet sys-libs/musl"
# Don't set packages so that baselayout won't be installed
PACKAGES_M="app-misc/figlet"
## I added this to bob-core/build.sh
BOB_SKIP_BASELAYOUT=1

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

	# We don't set PACKAGES to avoid installing a dynamically linked figlet
	# We want a static build but there's no static USE flag so we set CFLAGS, CXXFLAGS and LDFLAGS manually
	# We don't want to emerge the non-static binary package if it exists and emerge doesn't know not to because
	# the use flags will be the same, so let's exclude the binary package so we always compile from source
	# and hence honour our custom CFLAGS/CXXFLAGS/LDFLAGS
	CFLAGS="$(emerge --info|grep ^CFLAGS|grep -oP '(?<=").*(?=")') -static" \
	CXXFLAGS=$CFLAGS \
	LDFLAGS="$(emerge --info|grep LDFLAGS|grep -oP '(?<=").*(?=")') -static" \
	"${EMERGE_BIN}" ${EMERGE_OPT} --binpkg-respect-use=y --usepkg-exclude="$PACKAGES_M" -v $PACKAGES_M
	# As we broke the normal builder chain, recreate the docs for the busybox image
	init_docs "$PACKAGES_M"
	# XXX TODO would be nice to add/update fake USE flags +musl +static
	#update_use "$PACKAGES_M" "+musl +static"
	generate_doc_package_installed "$PACKAGES_M"
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build() {
	# figlist and showfig fonts are shell scripts needing /bin/sh, since we are building without a shell purge them too
	rm -f $EMERGE_ROOT/usr/bin/{figlist,showfigfonts}
	# let's assume we've tested the fonts and trust they are good, so hasta-la-vista chkfont
	rm $EMERGE_ROOT/usr/bin/chkfont
	# Only figlet let so let's move it and remove a directory
	mv $EMERGE_ROOT/usr/bin/figlet $EMERGE_ROOT/figlet
	rmdir $EMERGE_ROOT/usr/bin
	# no USE flag for bash-completion so just rm it
	rm -rf $EMERGE_ROOT/usr/share/bash-completion/
	# Not sure how to stop these
	rm -rf $EMERGE_ROOT/var/lib/gentoo
	rm -rf $EMERGE_ROOT/var
	# mostly coming from env-update, doesn't seem needed
	rm -rf $EMERGE_ROOT/etc
	# not sure where tmp is coming from
	rmdir $EMERGE_ROOT/tmp
	# to run as USER we need /etc/{passwd,group}
	mkdir -p $EMERGE_ROOT/etc
	# handle bug in portage when using custom root, user/groups created during install are not created at the custom root but on the host
	cp -f /etc/{passwd,group} $EMERGE_ROOT/etc
}
