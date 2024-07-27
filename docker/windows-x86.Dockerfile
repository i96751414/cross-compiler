ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

RUN apt-get update && apt-get install -y --no-install-recommends mingw-w64 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV CROSS_TRIPLE="i686-w64-mingw32"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
ENV CMAKE_TOOLCHAIN_FILE="/home/mingw.cmake"

COPY cmake/mingw.cmake "${CMAKE_TOOLCHAIN_FILE}"

# Use POSIX threading model for MINGW
# https://stackoverflow.com/questions/14191566/c-mutex-in-namespace-std-does-not-name-a-type/30849490
RUN update-alternatives --set "${CROSS_TRIPLE}-gcc" "/usr/bin/${CROSS_TRIPLE}-gcc-posix" \
    && update-alternatives --set "${CROSS_TRIPLE}-g++" "/usr/bin/${CROSS_TRIPLE}-g++-posix"

RUN ln -s "/usr/bin/${CROSS_TRIPLE}-gcc" "/usr/bin/${CROSS_TRIPLE}-cc"
