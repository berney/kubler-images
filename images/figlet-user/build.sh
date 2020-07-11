_packages="app-misc/figlet"

#
# this hook can be used to configure the build container itself, install packages, etc
#
configure_rootfs_build() {
	# this runs in the builder, but as one of the last build steps the builder's /etc/passwd is copied to the custom root
	useradd figlet
	# Create home directory in custom root
	#mkdir -p $EMERGE_ROOT/home/figlet
}
