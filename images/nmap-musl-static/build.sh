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
_packages="net-analyzer/nmap"
# Install a standard system directory layout at ${_EMERGE_ROOT}, optional, default: false
#BOB_INSTALL_BASELAYOUT=true

# Define custom variables to your liking
#_nmap-musl-static_version=1.0

#
# This hook can be used to configure the build container itself, install packages, run any command, etc
#
configure_bob()
{
    # Stolen from kubler/libressl-musl
    #add_layman_overlay libressl
    # libressl
    # https://wiki.gentoo.org/wiki/Project:LibreSSL
    echo "-libressl"               >> /etc/portage/profile/use.stable.mask 
    echo "-curl_ssl_libressl"      >> /etc/portage/profile/use.stable.mask 
    #echo "=dev-libs/libressl-2.4*" >> /etc/portage/package.accept_keywords/libressl
    emerge -f dev-libs/libressl
    emerge -C dev-libs/openssl net-misc/wget
    echo "dev-libs/openssl"        >> /etc/portage/package.mask/openssl
    update_use '+libressl'
    emerge -1 dev-libs/libressl net-misc/wget
    
    # Add our custom overlay
    add_overlay berne https://github.com/berney/gentoo-overlay.git
    #add_overlay berne file:///config/gentoo-overlay

    # Packages installed in this hook don't end up in the final image but are available for depending image builds
    #emerge dev-lang/go app-misc/foo
    :
    # our package
    #update_keywords '=net-analyzer/nmap-7.50' '+~amd64'
    #update_keywords '=net-analyzer/nmap-7.60' '+~amd64'
    #update_keywords '=net-analyzer/nmap-9999' '+~amd64'
    update_keywords '=net-analyzer/nmap-9999' '+**'
    update_use 'net-analyzer/nmap' '+ipv6' '+libressl' '+ncat' '-ndiff' '-nls' '-nmap-update' '+nping' '+nse' '+ssl' '-system-lua' '-zenmap' '+static' '+libssh2'
    # global
    #   - seems to cause problems (seems to work again, except for debianutils)
    update_use '+static-libs' '+minimal' '+static'
    # debianutils breaks on +static
    update_use 'sys-apps/debianutils' '-static'
    # targeted
    #update_use 'net-libs/libpcap' '+static-libs'
    #update_use 'sys-libs/zlib' '+static-libs'
    #update_use 'net-libs/libssh2' '+static-libs'
    #update_use 'dev-db/sqlite' '+static-libs'
    ##update_use 'sys-libs/ncurses' '+static-libs'
    ##update_use 'sys-libs/readline' '+static-libs'
    #update_use 'dev-libs/libpcre' '+static-libs'
    #update_use 'dev-lang/python' '+sqlite'
    #update_use 'dev-libs/libressl' '+static-libs'
    #update_use 'dev-libs/openssl' '+static-libs'

    # Need to unprovide libressl so that it will be rebuilt
    # This can be useful to install a package from a parent image again, it may be needed at build time
    unprovide_package dev-libs/libressl
    unprovide_package dev-libs/openssl
    unprovide_package sys-libs/zlib

    # emerge in builder to pull in dependencies
    emerge -vt net-analyzer/nmap
}

#
# This hook is called just before starting the build of the root fs
#
configure_rootfs_build()
{
    # Update a Gentoo package use flag..
    #update_use 'dev-libs/some-lib' '+feature' '-some_other_feature'

    # ..or a Gentoo package keyword
    #update_keywords 'dev-lang/some-package' '+~amd64'

    ## Add a package to Portage's package.provided file, effectively skipping it during installation
    ##provide_package 'dev-lang/some-package'
    provide_package 'net-libs/libpcap'
    provide_package 'sys-libs/zlib'
    provide_package 'sys-libs/ncurses'
    provide_package 'sys-libs/readline'
    provide_package 'dev-libs/libpcre'
    provide_package 'dev-libs/liblinear'
    provide_package 'dev-libs/libressl'
    provide_package 'net-libs/libssh2'

    # This can be useful to install a package from a parent image again, it may be needed at build time
    #unprovide_package 'dev-lang/some-package'

    # Only needed when ${_packages} is empty, initializes PACKAGES.md
    init_docs "berne/nmap-musl-static"
    
    # emerge in EMERGE_ROOT, we should already have all the dependencies built
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
    
    # Rice Rice Baby - rm stuff we don't want in the final image
    rm -rf "${_EMERGE_ROOT}"/etc
    rm -rf "${_EMERGE_ROOT}"/tmp
    rm -rf "${_EMERGE_ROOT}"/var
    # to run as a user you need /etc/{passwd,group}
    #mkdir -p "${_EMERGE_ROOT}"/etc
    # handle bug in portage when using custom root, user/groups created during install are not created at the custom root but on the host
    #cp -f /etc/{passwd,group} "${_EMERGE_ROOT}"/etc/

    # After installing packages manually you might want to add an entry to PACKAGES.md
    #log_as_installed "manual install" "nmap-musl-static-${_nmap-musl-static_version}" "https://nmap-musl-static.org/"
    :
}
