# Figlet Musl Static

Run this [figlet][] image with:

	$ docker run --rm berne/figlet-musl-static [<figlet options>] [message]

Actually run it with this:

	$ docker run --rm --read-only --network=none -m 32m --memory-swap 0 --cap-drop=all berne/figlet-musl-static [<figlet options>] [message]

## Minimalism

This is an exercise in minimalism.

- It's built with [gentoo-bb][]!
- It's a single static binary based off the [musl libc][] with its dependent font files.
- figlet won't compile with musl, so a small patch is made to fix its incompatibility.
  - [figlet-bug][]
  - [figlet-patch][]
- To apply the patch we use portage's [/etc/portage/patches][] feature.
  - We use the [/etc/portage/bashrc][] trick it details so that all ebuilds will apply patches.
- We don't use the standard `PACKAGES` variable to install figlet, because that causes baselayout to be installed.
  - If we just try to unmerge baselayout it will find non-empty directories and not remove any of the files in that directory.
  - So skipping installing it is easier.
  - We need to manually compile anyway to get a static build.
- There's no `static` USE flag for figlet, so we set `CFLAGS`, `CXXFLAGS`, and `LDFLAGS` for the `emerge`.
  - We exclude binary packages matching the atom since its USE flags will be the same to avoid getting a standard dynamically linked version.
  - It's not a long compile so not caching the build is't a big deal and this is an exercise in minimal image not build time.
- There's no bash-completion USE flag for use to disable so we just rm -rf `/usr/share/bash-completion`.
- We remove `figlist` and `showfigfonts` as they are scripts needing `/bin/sh` which doesn't exist.
- We assume we've tested all the fonts and trust they are good, so we rm them too.
- Since we only have the `figlet` binary left we move it to the root and remove the `/usr/bin/` directory.
- We remove `/var/`, and `/tmp/` directories.
- We remove everything but `/etc/passwd` and `/etc/group` from `/etc/`.
- To avoid making `/var`, `/run`, and '/var/run` I modified `gentoo-bb/bob-core/build-root.sh` to have a `SKIP_VAR_RUN_SYMLINK` variable
  that if set will skip that step, which is after the rootfs_finished hook.
  - This required rebuilding the core images.

## Security
- Like the figlet-user image we add a figlet user to run as so that we are not running as root.
- For more security run read-only: `docker run --read-only ...`
- For more security run with no network: `docker run --network=none ...`
- For more security limit memory utilisation: `docker run -m 32m --memory-swap 0 ...`
- For more security drop capabilities: `docker run --cap-drop=all ...`

## Entrypoint

This is designed to be run command style, so `ENTRYPOINT` is set to `./figlet`, and `CMD`s are arguments to `figlet`.

## Related images

- figlet
- figlet-user
- figlet-musl

[figlet]: http://www.figlet.org/
[gentoo-bb]: https://github.com/edannenberg/gentoo-bb
[musl libc]: https://www.musl-libc.org/
[figlet-bug]: https://bugs.gentoo.org/show_bug.cgi?id=608172
[figlet-patch]: https://github.com/alpinelinux/aports/blob/master/main/figlet/musl-fix-cplusplus-decls.patch
[/etc/portage/patches]: https://wiki.gentoo.org/wiki//etc/portage/patches
[/etc/portage/bashrc]: https://wiki.gentoo.org/wiki//etc/portage/patches#Enabling_.2Fetc.2Fportage.2Fpatches_for_all_ebuilds

