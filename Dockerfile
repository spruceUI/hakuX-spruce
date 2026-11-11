FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    python3 \
    git \
    ca-certificates \
    wget \
    xz-utils \
    llvm \
    && rm -rf /var/lib/apt/lists/*

ARG ZIG_VERSION=0.16.0
ARG ZIG_SHA256=70e49664a74374b48b51e6f3fdfbf437f6395d42509050588bd49abe52ba3d00
RUN wget -q https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz && \
    echo "${ZIG_SHA256}  zig-x86_64-linux-${ZIG_VERSION}.tar.xz" | sha256sum -c - && \
    mkdir /opt/zig && tar xJf zig-x86_64-linux-${ZIG_VERSION}.tar.xz -C /opt/zig --strip-components=1 && \
    rm zig-x86_64-linux-${ZIG_VERSION}.tar.xz
ENV PATH="/opt/zig:${PATH}"

# An arm64 SDL2 to link against only; devices bring their own.
RUN dpkg --add-architecture arm64 && \
    sed -i 's/^Types: deb$/Types: deb\nArchitectures: amd64/' /etc/apt/sources.list.d/ubuntu.sources && \
    printf 'Types: deb\nURIs: http://ports.ubuntu.com/ubuntu-ports\nSuites: noble noble-updates\nComponents: main universe\nArchitectures: arm64\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n' \
        > /etc/apt/sources.list.d/arm64.sources && \
    apt-get update && mkdir /tmp/sdl && cd /tmp/sdl && \
    apt-get download libsdl2-2.0-0:arm64 && dpkg-deb -x libsdl2-2.0-0_*.deb . && \
    mkdir -p /opt/sdl2 && cp -L usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 /opt/sdl2/libSDL2.so && \
    cd / && rm -rf /tmp/sdl /var/lib/apt/lists/*

COPY build.sh /build.sh
RUN chmod +x /build.sh
COPY patches/ /patches/

WORKDIR /build
ENTRYPOINT ["/build.sh"]
