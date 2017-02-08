# gentoo-bb-images
My namespace for [gentoo-bb][] to build my [ricer][] images.

## gentoo-bb

Build framework to produce minimal root file systems based on Gentoo. It's primarily intended for maintaining an organization's LXC base image stack(s), but can probably fairly easy (ab)used for other use cases involving a custom root fs, cross compiling comes to mind.

## Quick Start

1. You need [gentoo-bb][]:
   `git clone https://github.com/edannenberg/gentoo-bb.git`

2. Add my namespace:
   ```
   cd gentoo-bb/dock
   git clone git@github.com:berney/gentoo-bb-images.git berne
   cd ..
   ```
3. Build my namespace:
   `./build.sh build berne`
   



### My gentoo-bb fork

All of these images should generally build off the upstream [gentoo-bb][], there might be some (should be documented) that
need [my fork][]. I generally upstream all my changes as PRs, so unless I'm doing something funky you shouldn't need my
fork of gentoo-bb.

[gentoo-bb]: https://github.com/edannenberg/gentoo-bb
[my fork]: https://github.com/berney/gentoo-bb
[ricer]: https://fun.irq.dk/funroll-loops.org/
