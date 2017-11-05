### berne/nmap:20170925

Built: Wed Oct 18 01:03:49 GMT 2017
Image Size: 42.3MB

#### Installed
Package | USE Flags
--------|----------
app-arch/bzip2-1.0.6-r8 | `-static -static-libs`
app-misc/ca-certificates-20161130.3.30.2 | `-cacert -insecure`
app-misc/c_rehash-1.7-r1 | ``
dev-libs/liblinear-210-r1 | `-blas`
dev-libs/libpcre-8.41 | `bzip2 cxx readline recursion-limit (unicode) zlib -jit -libedit -pcre16 -pcre32 -static-libs`
dev-libs/openssl-1.0.2l | `asm sslv3 tls-heartbeat zlib -bindist -gmp -kerberos -rfc3779 -sctp -sslv2 -static-libs {-test} -vanilla`
net-analyzer/nmap-7.40 | `nls nse ssl -ipv6 (-libressl) -ncat -ndiff -nmap-update -nping (-system-lua) -zenmap`
net-libs/libpcap-1.8.1 | `-bluetooth -dbus -netlink -static-libs -usb`
sys-apps/debianutils-4.7 | `-static`
sys-libs/ncurses-6.0-r1 | `cxx threads unicode -ada -debug -doc -gpm -minimal (-profile) -static-libs {-test} -tinfo -trace`
sys-libs/readline-6.3_p8-r3 | `-static-libs -utils`
sys-libs/zlib-1.2.11-r1 | `-minizip -static-libs`
#### Inherited
Package | USE Flags
--------|----------
**FROM kubler/glibc** |
sys-apps/gentoo-functions-0.12 | ``
sys-libs/glibc-2.23-r4 | `hardened rpc -audit -caps -debug -gd (-multilib) -nscd (-profile) (-selinux) -suid -systemtap (-vanilla)`
sys-libs/timezone-data-2017a | `nls -leaps`
**FROM kubler/busybox** |
sys-apps/busybox-1.25.1 | `make-symlinks static -debug -ipv6 -livecd -math -mdev -pam -savedconfig (-selinux) -sep-usr -syslog -systemd`
#### Purged
- [x] Headers
- [x] Static Libs
