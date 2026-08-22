# This is a Dockerfile intended to be built using `docker buildx`
# for multi-arch support. Building with `docker build` may have unexpected results.
FROM lscr.io/linuxserver/qbittorrent:latest AS base

# arm64-specific stage
FROM base AS build-arm64
ARG ARCH=arm64  # qui uses "arm64" not "aarch64"

# amd64-specific stage
FROM base AS build-amd64
ARG ARCH=x86_64

FROM build-${TARGETARCH} AS build

ARG ARCH
ARG INCLUDES_BASEURL="https://raw.githubusercontent.com/braingremlin85/docker-qbittorent-qui/master/includes/"
#ARG INCLUDES_BASEURL="includes/" # use this for local build

RUN apk update && apk upgrade

RUN wget -O qui.tar.gz "$(curl -s https://api.github.com/repos/autobrr/qui/releases/latest | grep browser_download_url | grep "linux_${ARCH}" | cut -d\" -f4)" \
    && tar -C /usr/bin -xzf qui.tar.gz \
    && chmod +x /usr/bin/qui \
    && rm qui.tar.gz

# run qui
ADD ${INCLUDES_BASEURL}/svc-qui/svc-qui-type /etc/s6-overlay/s6-rc.d/svc-qui/type
ADD ${INCLUDES_BASEURL}/svc-qui/svc-qui-run /etc/s6-overlay/s6-rc.d/svc-qui/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/svc-qui/run
RUN	mkdir /etc/s6-overlay/s6-rc.d/svc-qui/dependencies.d && touch /etc/s6-overlay/s6-rc.d/svc-qui/dependencies.d/svc-qbittorrent
RUN	touch /etc/s6-overlay/s6-rc.d/user/contents.d/svc-qui


EXPOSE 8080/tcp
EXPOSE 7476/tcp
EXPOSE 6881/tcp
EXPOSE 6881/udp