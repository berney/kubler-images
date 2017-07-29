#
# Kubler phase 1 config, pick installed packages and/or customize the build
#

# The recommended way to install software is setting ${_packages}
# List of Gentoo package atoms to be installed at custom root fs ${_EMERGE_ROOT}, optional, space separated
# If you are not sure about package names you may want to start an interactive build container:
#     kubler.sh build -i berne/nmap-musl-static
# ..and then search the Portage database:
#     eix <search-string>
#_packages="net-analyzer/nmap app-misc/pax-utils sys-libs/musl sys-apps/file app-shells/bash"
#_packages="net-analyzer/nmap"
_packages=""
_packages_m="net-analyzer/nmap"
# Install a standard system directory layout at ${_EMERGE_ROOT}, optional, default: false
#BOB_INSTALL_BASELAYOUT=true

# Define custom variables to your liking
#_nmap-musl-static_version=1.0

#
# This hook can be used to configure the build container itself, install packages, run any command, etc
#
configure_bob()
{
    # Packages installed in this hook don't end up in the final image but are available for depending image builds
    #emerge dev-lang/go app-misc/foo
    :
    # our package
    #update_use 'net-analyzer/nmap' '-ipv6' '-libressl' '-ncat' '-ndiff' '-nls' '-nmap-update' '-nping' '-nse' '-ssl' '-system-lua' '-zenmap'
    update_use 'net-analyzer/nmap' '-ipv6' '-libressl' '+ncat' '-ndiff' '-nls' '-nmap-update' '-nping' '-nse' '-ssl' '-system-lua' '-zenmap'
    #update_use 'net-analyzer/nmap' '+ipv6' '+libressl' '+ncat' '+ndiff' '-nls' '-nmap-update' '+nping' '+nse' '-ssl' '-system-lua' '-zenmap'
    # global
    #   - seems to cause problems
    #update_use '+static-libs' '+minimal' '+static'
    # targeted
    update_use 'net-libs/libpcap' '+static-libs'
    update_use 'sys-libs/zlib' '+static-libs'
    update_use 'sys-libs/ncurses' '+static-libs'
    update_use 'sys-libs/readline' '+static-libs'
    update_use 'dev-libs/libpcre' '+static-libs'

    # emerge in builder to pull in dependencies
    emerge -vt net-analyzer/nmap
    # for some reason the +static-libs change is not seen/picked up so the -static-libs version is left installed
    emerge -1vt dev-libs/libpcre
    
    # copy /config/etc/portage/env/net-analyzer/nmap /etc/portage/env/net-analyzer/nmap
    mkdir -p /etc/portage/env/net-analyzer
    echo 'CFLAGS="$CFLAGS -static -static-libgcc -fPIC"' >> /etc/portage/env/net-analyzer/nmap 
    echo 'CXXFLAGS="$CXXFLAGS -static -static-libstdc++ -static-libgcc -fPIC"' >> /etc/portage/env/net-analyzer/nmap 
    echo 'LDFLAGS="$LDFLAGS -static -fuse-ld=gold"' >> /etc/portage/env/net-analyzer/nmap 
}

#
# This hook is called just before starting the build of the root fs
#
configure_rootfs_build()
{
    # Update a Gentoo package use flag..
    #update_use 'dev-libs/some-lib' '+feature' '-some_other_feature'
    #update_use 'net-analyzer/nmap' '-ipv6' '-libressl' '-ncat' '-ndiff' '-nls' '-nmap-update' '-nping' '-nse' '-ssl' '-system-lua' '-zenmap'
    #update_use 'net-analyzer/nmap' '+ipv6' '+libressl' '+ncat' '+ndiff' '-nls' '-nmap-update' '+nping' '+nse' '+ssl' '-system-lua' '-zenmap'

    # ..or a Gentoo package keyword
    #update_keywords 'dev-lang/some-package' '+~amd64'

    # Add a package to Portage's package.provided file, effectively skipping it during installation
    #provide_package 'dev-lang/some-package'
    provide_package 
    provide_package 'net-libs/libpcap'
    provide_package 'sys-libs/zlib'
    provide_package 'sys-libs/ncurses'
    provide_package 'sys-libs/readline'
    provide_package 'dev-libs/libpcre'

    # This can be useful to install a package from a parent image again, it may be needed at build time
    #unprovide_package 'dev-lang/some-package'

    # Only needed when ${_packages} is empty, initializes PACKAGES.md
    init_docs "berne/nmap-musl-static"
    echo "was CFLAGS: $CFLAGS, CXXFLAGS: $CXXFLAGS, LDFLAGS: $LDFLAGS"
    #CFLAGS="$CFLAGS -static"
    #CXXFLAGS="$CXXFLAGS -static"
    #LDFLAGS="$LDFLAGS -static"
    #echo "now CFLAGS: $CFLAGS, CXXFLAGS: $CXXFLAGS, LDFLAGS: $LDFLAGS"
    
    # emerge in EMERGE_ROOT, we should already have all the dependencies built
    # - always compile from source to ensure our env overide is honoured
    ROOT="${_EMERGE_ROOT}" $_emerge_bin $_emerge_opt --usepkg-exclude="$_packages_m" -v $_packages_m
    generate_doc_package_installed "$_packages_m"
    :
}

#
# This hook is called just before packaging the root fs tar ball, ideal for any post-install tasks, clean up, etc
#
finish_rootfs_build()
{
    # Useful helpers

    # install su-exec at ${_EMERGE_ROOT}
    #install_suexec
    # Copy c++ libs, may be needed if you see errors regarding missing libstdc++
    #copy_gcc_libs

    # Example for a manual build if _packages method does not suffice, a typical use case is a Go project:

    #export GOPATH="/go"
    #export PATH="${PATH}:/go/bin"
    #export DISTRIBUTION_DIR="${GOPATH}/src/github.com/berne/nmap-musl-static"
    #mkdir -p "${DISTRIBUTION_DIR}"

    #git clone https://github.com/berne/nmap-musl-static.git "${DISTRIBUTION_DIR}"
    #cd "${DISTRIBUTION_DIR}"
    #git checkout tags/v${_nmap-musl-static_version}
    #echo "building nmap-musl-static ${_nmap-musl-static_version}.."
    #go run build.go build
    #mkdir -p "${_EMERGE_ROOT}"/usr/local/{bin,share}

    # Everything at ${_EMERGE_ROOT} will end up in the final image
    #cp -rp "${DISTRIBUTION_DIR}/bin/*" "${_EMERGE_ROOT}/usr/local/bin"

    # After installing packages manually you might want to add an entry to PACKAGES.md
    #log_as_installed "manual install" "nmap-musl-static-${_nmap-musl-static_version}" "https://nmap-musl-static.org/"
    :
}
