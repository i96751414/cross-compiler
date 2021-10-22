FROM debian:stretch

ARG CMAKE_VERSION=3.20.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https gnupg ca-certificates \
    curl wget \
    pkg-config build-essential make automake autogen libtool \
    libpcre3-dev bison yodl \
    tar xz-utils bzip2 gzip unzip \
    git \
    file \
    rsync \
    upx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh" \
        --no-check-certificate -qO /tmp/cmake-install.sh \
    && chmod +x /tmp/cmake-install.sh \
    && mkdir /usr/bin/cmake \
    && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
    && rm /tmp/*

ENV PATH="/usr/bin/cmake/bin:${PATH}"
