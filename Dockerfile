# Tor 0.3.2.10

FROM armhf/alpine:latest
MAINTAINER pajdk "https://hub.docker.com/r/pajdk/rpi-tor/"

EXPOSE 9001 9050

RUN build_pkgs=" \
        openssl-dev \
        zlib-dev \
        libevent-dev \
        gnupg \
        " \
  && runtime_pkgs=" \
        build-base \
        openssl \
        zlib \
        libevent \
        " \
  && apk --update add ${build_pkgs} ${runtime_pkgs}
RUN cd /tmp \
  && wget https://www.torproject.org/dist/tor-0.3.2.10.tar.gz \
  && wget https://www.torproject.org/dist/tor-0.3.2.10.tar.gz.asc \
  && gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 0x9E92B601 \
  && gpg --verify tor-0.3.2.10.tar.gz.asc \
  && tar xzvf tor-0.3.2.10.tar.gz \
  && cd /tmp/tor-0.3.2.10 \
  && ./configure \
  && make -j6 \
  && make install \
  && cd \
  && rm -rf /tmp/* \
  && apk del ${build_pkgs} \
  && rm -rf /var/cache/apk/*

RUN adduser -Ds /bin/sh tor

RUN mkdir /etc/tor
COPY torrc /etc/tor/

RUN mkdir /home/tor/.tor && chown tor:tor /home/tor/.tor -R

USER tor
CMD ["tor", "-f", "/etc/tor/torrc"]
