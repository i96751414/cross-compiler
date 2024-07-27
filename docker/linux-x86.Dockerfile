ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc-multilib \
        g++-multilib \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV CROSS_TRIPLE="i686-linux-gnu"
ENV CROSS_ROOT="/usr/i686-linux-gnu"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
ENV CMAKE_TOOLCHAIN_FILE="/home/linux.cmake"

COPY cmake/linux.cmake "${CMAKE_TOOLCHAIN_FILE}"

COPY "scripts/${CROSS_TRIPLE}.sh" "/usr/bin/${CROSS_TRIPLE}.sh"
RUN mkdir -p ${CROSS_ROOT} \
    && chmod +x /usr/bin/${CROSS_TRIPLE}.sh \
    && ln -s "/usr/bin/x86_64-linux-gnu-gcc" "/usr/bin/x86_64-linux-gnu-cc" \
    && ln -s "/usr/bin/x86_64-linux-gnu-g++" "/usr/bin/x86_64-linux-gnu-c++" \
    && for i in gcc cc g++ c++; do \
        ln -s "/usr/bin/${CROSS_TRIPLE}.sh" "/usr/bin/${CROSS_TRIPLE}-${i}" ; \
    done \
    && for i in strip objdump; do \
        ln -s "/usr/bin/${i}" "/usr/bin/${CROSS_TRIPLE}-${i}" ; \
    done \
    && for i in ranlib nm ar; do \
        ln -s "/usr/bin/x86_64-linux-gnu-gcc-${i}" "/usr/bin/${CROSS_TRIPLE}-${i}" ; \
    done
