#
# Kubler phase 1 config, pick installed packages and/or customize the build
#

# The recommended way to install software is setting ${_packages}
# List of Gentoo package atoms to be installed at custom root fs ${_EMERGE_ROOT}, optional, space separated
# If you are not sure about package names you may want to start an interactive build container:
#     kubler.sh build -i berne/nmap
# ..and then search the Portage database:
#     eix <search-string>
_packages="net-analyzer/nmap"
# Install a standard system directory layout at ${_EMERGE_ROOT}, optional, default: false
#BOB_INSTALL_BASELAYOUT=true

# Define custom variables to your liking
#_nmap_version=1.0

#
# This hook can be used to configure the build container itself, install packages, run any command, etc
#
configure_bob()
{
    # Packages installed in this hook don't end up in the final image but are available for depending image builds
    #emerge dev-lang/go app-misc/foo
    :
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

    # Add a package to Portage's package.provided file, effectively skipping it during installation
    #provide_package 'dev-lang/some-package'

    # This can be useful to install a package from a parent image again, it may be needed at build time
    #unprovide_package 'dev-lang/some-package'

    # Only needed when ${_packages} is empty, initializes PACKAGES.md
    #init_docs "berne/nmap"
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
    copy_gcc_libs

    # Example for a manual build if _packages method does not suffice, a typical use case is a Go project:

    #export GOPATH="/go"
    #export PATH="${PATH}:/go/bin"
    #export DISTRIBUTION_DIR="${GOPATH}/src/github.com/berne/nmap"
    #mkdir -p "${DISTRIBUTION_DIR}"

    #git clone https://github.com/berne/nmap.git "${DISTRIBUTION_DIR}"
    #cd "${DISTRIBUTION_DIR}"
    #git checkout tags/v${_nmap_version}
    #echo "building nmap ${_nmap_version}.."
    #go run build.go build
    #mkdir -p "${_EMERGE_ROOT}"/usr/local/{bin,share}

    # Everything at ${_EMERGE_ROOT} will end up in the final image
    #cp -rp "${DISTRIBUTION_DIR}/bin/*" "${_EMERGE_ROOT}/usr/local/bin"

    # After installing packages manually you might want to add an entry to PACKAGES.md
    #log_as_installed "manual install" "nmap-${_nmap_version}" "https://nmap.org/"
    :
}
