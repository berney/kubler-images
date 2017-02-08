# gentoo-bb-images

My namespace for [gentoo-bb][] to build my [ricer][] images.
- This is my source/templates that build my Docker images.
- Slim Docker images based on Gentoo.
- Generally opinionated, these are my images after all.


## What is gentoo-bb

[gentoo-bb][] is an excellent build framework to produce minimal Docker images, and minimal root file systems based on Gentoo. It's primarily intended for maintaining an organization's LXC base image stack(s), but can probably fairly easy (ab)used for other use cases involving a custom root fs, cross compiling comes to mind.


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
   

## Goals

I strive to have high quality optimal images that have at least one but hopefully all of the following attributes:
- Follow Docker best practices
  - This is a nice [docker-best-practices][summary] of them.
- Minimal
  - No bloat
- Performant
- Secure
  - Principal of least privilege
  - A bunch of the Docker best practices are security related
- Correct
  - They should actually work.
  - Automated Testing
- Clean beautiful code
- Documented



## Reasons Why / Why Not

### Why not just use Docker Hub

Most images are ~shit~ sub-optimal IMO
- Bloaty
- Insecure
- Don't follow Docker's best practices
- Source might not be available
- Hard to understand/reason 


### Why not just use Alpine

Alpine is a great base for images.
This is to ricer things, go that one step further in minimalism, security hardening, optimisation, or have software or a feature or
setup that's not available out of the box in alpine with `apk`.
With gentoo-bb we get the power and flexibility of Gentoo plus the separation of build-time dependencies and run time dependencies.


## Todo / Wishlist

- Automated testing of resultant images to ensure they are functioning correctly.
  - If you know of good tools or have good ideas in this regard please let me know.
- Automated scanning of resultant images for security issues.


## Git Branching Model

- The `master` branch should always be stable, production-ready, building working images.
- New images that are WIP will be in feature branches.
  - Once they are working they'll get merged into `master`



## Contributions

PRs are welcome, if I like your ideas I'll use them. See my wishlist above. Keep in mind this is my opinionated stake on
how Docker images should be, and our goals might differ.


## My gentoo-bb fork

All of these images should generally build off the upstream [gentoo-bb][], there might be some (should be documented) that
need [my fork][]. I generally upstream all my changes as PRs, so unless I'm doing something funky you shouldn't need my
fork of gentoo-bb.


[gentoo-bb]: https://github.com/edannenberg/gentoo-bb
[my fork]: https://github.com/berney/gentoo-bb
[ricer]: https://fun.irq.dk/funroll-loops.org/
[Branching Model]: http://nvie.com/posts/a-successful-git-branching-model/
