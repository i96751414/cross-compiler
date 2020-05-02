ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

RUN apt-get update && apt-get -y install crossbuild-essential-arm64

ENV CROSS_TRIPLE aarch64-linux-gnu
ENV CROSS_ROOT /usr/${CROSS_TRIPLE}
ENV PATH ${PATH}:${CROSS_ROOT}/bin
ENV LD_LIBRARY_PATH ${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}
ENV PKG_CONFIG_PATH ${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}

RUN cd /usr/bin && \
    ln -s aarch64-linux-gnu-gcc-6 ${CROSS_TRIPLE}-cc && \
    ln -s aarch64-linux-gnu-g++-6 ${CROSS_TRIPLE}-c++
