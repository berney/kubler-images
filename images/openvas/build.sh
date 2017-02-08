PACKAGES="net-analyzer/openvas net-analyzer/nikto net-analyzer/nmap net-analyzer/ike-scan net-analyzer/amap app-forensics/ovaldi net-analyzer/w3af net-analyzer/greenbone-security-assistant sys-apps/openrc sys-apps/iproute2"


#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build() {
	update_keywords 'net-analyzer/openvas-libraries' '+~amd64'
	update_keywords 'net-analyzer/openvas-tools' '+~amd64'
	update_keywords 'net-analyzer/openvas-cli' '+~amd64'
	update_keywords 'net-analyzer/openvas-manager' '+~amd64'
	update_keywords 'net-analyzer/openvas-scanner' '+~amd64'
	update_keywords 'net-analyzer/openvas' '+~amd64'
	update_keywords 'net-analyzer/ike-scan' '+~amd64'
	update_keywords 'app-forensics/ovaldi' '+~amd64'
	update_keywords 'net-libs/libwhisker' '+~amd64'
	update_keywords 'net-analyzer/nikto' '+~amd64'
	update_keywords 'net-analyzer/greenbone-security-assistant' '+~amd64'
	update_use 'net-libs/libmicrohttpd' '+messages'
}

finish_rootfs_build() {
	copy_gcc_libs
	# openvas-libraries creates a /var/run directory, it should be a symlink to /run, build-root will create after this callback
	echo ls -ld $EMERGE_ROOT/var/run 
	ls -ld $EMERGE_ROOT/var/run || true
	echo ls -l $EMERGE_ROOT/var/run
	ls -l $EMERGE_ROOT/var/run || true

	echo rmdir -v $EMERGE_ROOT/var/run
	rmdir -v $EMERGE_ROOT/var/run || true

	echo ls -ld $EMERGE_ROOT/var/run
	ls -ld $EMERGE_ROOT/var/run || true
	echo ls -l $EMERGE_ROOT/var/run
	ls -l $EMERGE_ROOT/var/run || true
}
