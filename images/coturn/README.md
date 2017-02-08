# docker-coturn

[Coturn][] TURN Server

This is based on the work of serveral other projects.


## How to use

This image has no configuration, so it will use defaults. To use it with defaults run the following:

```
docker run \
    -d \
    --name coturn \
    -p $EXT_IP:3478:3478/udp \
    -p $EXT_IP:3479:3479/udp \
    -p $EXT_IP:5349:5349/udp \
    -p $EXT_IP:5350:5350/udp \
    -p $EXT_IP:3478:3478 \
    -p $EXT_IP:3479:3479 \
    -p $EXT_IP:5349:5349 \
    -p $EXT_IP:5350:5350 \
    berne/coturn
```

The default config might not be suitable for your needs, to change the configuration you can do the following:

Dockerfile:

```
FROM berne/coturn
ADD etc /etc
```

Modify `etc/turnserver.conf` as you see fit. Other files in etc/ will also be overlayed, so you can update `etc/services/turnserver/run` as well if you desire.

Build the new image: `docker build -t myname/coturn:mytag --rm .`. Run the new image similar to above.


## Comparison to other coturn based Docker images

 - [bprodoehl/turnserver][] is based on chubby phusion/baseimage, which is based on tubby-wubby ubuntu
 - [syntree/coturn][] is based on fatty debian:jessie but runs the turnserver directly in the container as PID 1, without a supervisor.
 - [ianblenke/coturn][] alpine-based, runs as PID 1 without a supervisor, uses host network via docker-compose
 - [excession/coturn][] not open-source (AFAICT)


## Why berney/coturn

 - Built using [gentoo-bb]
   - Similar to ubuntu/debian vs alpine, this is lean
 - [S6][] supervision
 - Designed to be used without privileged, security-risk, host-networking
 - Designed to be used with firewall friendly static ports
 - Open Source


## Arbitrary Ports

Due to the need for the TURN server to open arbitrary ports to the outside world and Docker's lack of range-based port mapping (https://github.com/docker/docker/issues/8899), additional configuration is needed to allow clients to talk to this service. This can be accomplished in a number of ways, including the use of iptables in combination with something like [docker-gen] or using Docker's host networking (--net host) feature. The use of host networking is not recommended due to the many security issues it raises.

See Jason Wilder's excellent blog [article][jwilder-blog] for the full details on docker-gen.


## Testing

You can use [TrickleICE] to test the trickle ICE functionality in your WebRTC application, with the add server control.

Chrome has these that can help with troubleshooting:
  - [webrtc-internals][] - See call data etc.
  - [webrtc-logs][] - See PeerConnections, logs of API calls, etc.


[Coturn]: https://github.com/coturn/coturn
[bprodoehl/turnserver]: https://github.com/bprodoehl/docker-turnserver
[syntree/coturn]: https://github.com/synctree/docker-coturn)
[ianblenke/coturn]: https://github.com/ianblenke/docker-coturn
[gentoo-bb]: https://github.com/edannenberg/gentoo-bb
[S6]: http://skarnet.org/software/s6/index.html
[docker-gen]: https://github.com/jwilder/docker-gen
[jwilder-blog]: http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/
[excession/coturn]: https://hub.docker.com/r/excession/coturn/
[TrickleICE]: https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/
[webrtc-internals]: chrome://webrtc-internals
[webrtc-logs]: chrome://webrtc-logs
