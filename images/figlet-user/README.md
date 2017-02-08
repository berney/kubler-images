# figlet-user

This basically the gentoo-bb README.md example but modified so that figlet runs as a unprivileged user rather than as the super-user root.

Run this [figlet][] image with:

        $ docker run --rm berne/figlet-user [<figlet options>] [message]


## Related images

- figlet
- figlet-musl
- figlet-musl-static

## Thanks

Thanks to @edannenberg not just for the excellent [gentoo-bb][] tool but also for the great [support][].

[figlet]: http://www.figlet.org/
[gentoo-bb]: https://github.com/edannenberg/gentoo-bb
[support]: https://github.com/edannenberg/gentoo-bb/issues/66
