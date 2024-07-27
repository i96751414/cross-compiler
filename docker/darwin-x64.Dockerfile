ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ENV CROSS_TRIPLE="x86_64-apple-darwin17"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="/usr/lib/llvm-7/lib:${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
ENV MAC_SDK_VERSION="10.13"
ENV CMAKE_TOOLCHAIN_FILE="/home/darwin.cmake"

COPY cmake/darwin.cmake "${CMAKE_TOOLCHAIN_FILE}"

RUN echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-7 main" >> /etc/apt/sources.list \
    && wget --no-check-certificate -qO - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        clang-7 llvm-7-dev \
        lzma-dev libxml2-dev uuid-dev libssl-dev \
        python3 patch cpio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/osxcross \
    && curl -sSL "https://github.com/tpoechtrager/osxcross/archive/master.tar.gz" | tar -C /tmp/osxcross --strip=1 -xz \
    && curl -sSLo "/tmp/osxcross/tarballs/MacOSX${MAC_SDK_VERSION}.sdk.tar.xz" \
        "https://github.com/i96751414/MacOSX-SDKs/raw/master/MacOSX${MAC_SDK_VERSION}.sdk.tar.xz" \
    && ln -s /usr/bin/clang-7 /usr/bin/clang \
    && ln -s /usr/bin/clang++-7 /usr/bin/clang++ \
    && SDK_VERSION=${MAC_SDK_VERSION} OSX_VERSION_MIN=10.9 UNATTENDED=1 /tmp/osxcross/build.sh \
    && mv /tmp/osxcross/target "${CROSS_ROOT}" \
    && mkdir -p "${CROSS_ROOT}/lib" \
    && rm -rf /tmp/osxcross
