ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ENV CROSS_TRIPLE="x86_64-linux-gnu"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
ENV CMAKE_TOOLCHAIN_FILE="/home/linux.cmake"

COPY cmake/linux.cmake "${CMAKE_TOOLCHAIN_FILE}"

RUN mkdir -p "${CROSS_ROOT}" \
    && ln -s "/usr/bin/${CROSS_TRIPLE}-gcc" "/usr/bin/${CROSS_TRIPLE}-cc" \
    && ln -s "/usr/bin/${CROSS_TRIPLE}-g++" "/usr/bin/${CROSS_TRIPLE}-c++"
