ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ENV CROSS_TRIPLE x86_64-apple-darwin15
ENV CROSS_ROOT /usr/${CROSS_TRIPLE}
ENV PATH ${PATH}:${CROSS_ROOT}/bin
ENV LD_LIBRARY_PATH /usr/lib/llvm-4.0/lib:${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}
ENV PKG_CONFIG_PATH ${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}
ENV MAC_SDK_VERSION 10.11

RUN echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-4.0 main" >> /etc/apt/sources.list \
    && wget --no-check-certificate -qO - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        clang-4.0 llvm-4.0-dev \
        lzma-dev libxml2-dev uuid-dev libssl-dev \
        python3 patch cpio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://github.com/tpoechtrager/osxcross/archive/master.tar.gz" | tar xz \
    && curl -Lo "/osxcross-master/tarballs/MacOSX${MAC_SDK_VERSION}.sdk.tar.xz" \
        "https://s3.amazonaws.com/beats-files/deps/MacOSX${MAC_SDK_VERSION}.sdk.tar.xz" \
    && ln -s /usr/bin/clang-4.0 /usr/bin/clang \
    && ln -s /usr/bin/clang++-4.0 /usr/bin/clang++ \
    && SDK_VERSION=${MAC_SDK_VERSION} OSX_VERSION_MIN=10.10 UNATTENDED=1 /osxcross-master/build.sh \
    && mv /osxcross-master/target "${CROSS_ROOT}" \
    && mkdir -p "${CROSS_ROOT}/lib" \
    && rm -rf /osxcross-master
