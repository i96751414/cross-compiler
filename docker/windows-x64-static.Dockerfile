ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

COPY scripts/build-mxe-toolchain.sh /scripts/
RUN ./scripts/build-mxe-toolchain.sh --prefix /usr --arch x86_64 --link static --install-dependencies \
    && rm -rf /scripts \

ENV CROSS_TRIPLE="x86_64-w64-mingw32.static"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
ENV CMAKE_TOOLCHAIN_FILE="${CROSS_ROOT}/share/cmake/mxe-conf.cmake"

ENV AS=/usr/bin/${CROSS_TRIPLE}-as \
    AR=/usr/bin/${CROSS_TRIPLE}-ar \
    CC=/usr/bin/${CROSS_TRIPLE}-gcc \
    CPP=/usr/bin/${CROSS_TRIPLE}-cpp \
    CXX=/usr/bin/${CROSS_TRIPLE}-g++ \
    LD=/usr/bin/${CROSS_TRIPLE}-ld \
    FC=/usr/bin/${CROSS_TRIPLE}-gfortran
