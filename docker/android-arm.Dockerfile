ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ENV CROSS_TRIPLE arm-linux-androideabi
ENV CROSS_ROOT /usr/${CROSS_TRIPLE}
ENV PATH ${PATH}:${CROSS_ROOT}/bin
ENV LD_LIBRARY_PATH ${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}
ENV PKG_CONFIG_PATH ${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}

ENV SYSTEM_PROCESSOR armv7-a
ENV ANDROID_ARCH_ABI armeabi-v7a
ENV CMAKE_TOOLCHAIN_FILE /home/android.cmake

COPY cmake/android.cmake "${CMAKE_TOOLCHAIN_FILE}"

RUN apt-get update && apt-get install -y --no-install-recommends python \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV NDK android-ndk-r20
ENV ANDROID_NDK_API 21
ENV ANDROID_ARCH arm

COPY scripts/build_android_toolchain.sh /scripts/
RUN ./scripts/build_android_toolchain.sh \
    && rm -rf /scripts

RUN ln -s "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-clang" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cc"
