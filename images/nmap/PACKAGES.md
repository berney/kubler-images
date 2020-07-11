### kubler-images/nmap:20200707

Built: Tue Jul  7 20:44:07 AEST 2020
Image Size: 49.7MB

#### Installed
Package | USE Flags
--------|----------
app-arch/bzip2-1.0.6-r11 | `(split-usr) -static -static-libs`
app-misc/ca-certificates-20200601.3.53 | `-cacert`
app-misc/c_rehash-1.7-r1 | ``
dev-libs/liblinear-210-r1 | ``
dev-libs/libpcre-8.43 | `bzip2 cxx readline recursion-limit (split-usr) (unicode) zlib -jit -libedit -pcre16 -pcre32 -static-libs`
dev-libs/openssl-1.1.1g | `asm zlib -bindist -rfc3779 -sctp -sslv3 -static-libs -test -tls-heartbeat -vanilla`
net-analyzer/nmap-7.80-r1 | `nse ssl -ipv6 -libressl -libssh2 -ncat -nmap-update -nping (-system-lua)`
net-libs/libpcap-1.9.1 | `-bluetooth -dbus -netlink -static-libs -usb`
sys-apps/debianutils-4.9.1 | `installkernel -static`
sys-kernel/installkernel-gentoo-2 | ``
sys-libs/ncurses-6.2-r1 | `cxx (split-usr) threads (tinfo) unicode -ada -debug -doc -gpm -minimal -profile -static-libs -test -trace`
sys-libs/readline-8.0_p4 | `(split-usr) unicode -static-libs -utils`
sys-libs/zlib-1.2.11-r2 | `(split-usr) -minizip -static-libs`
#### Inherited
Package | USE Flags
--------|----------
**FROM kubler/glibc** |
dev-libs/libunistring-0.9.10 | `-doc -static-libs`
net-dns/libidn2-2.3.0 | `-static-libs`
sys-apps/gentoo-functions-0.12 | ``
sys-libs/glibc-2.30-r8 | `(crypt) multiarch (ssp) (static-libs) -audit -caps (-cet) -compile-locales -custom-cflags -doc -gd -headers-only (-multilib) -nscd -profile (-selinux) -suid -systemtap -test (-vanilla)`
sys-libs/timezone-data-2020a | `nls -leaps-timezone`
**FROM kubler/busybox** |
sys-apps/busybox-1.31.1-r2 | `make-symlinks static -debug -ipv6 -livecd -math -mdev -pam -savedconfig (-selinux) -sep-usr -syslog -systemd`
sys-apps/sed-4.8 | `static -acl -nls (-selinux)`
#### Purged
- [x] Headers
- [x] Static Libs
