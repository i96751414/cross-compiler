ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ENV CROSS_TRIPLE="arm-linux-androideabi"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV ANDROID_NDK="${CROSS_ROOT}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"

ENV SYSTEM_PROCESSOR="armv7-a"
ENV ANDROID_ARCH_ABI="armeabi-v7a"
ENV CMAKE_TOOLCHAIN_FILE="/home/android.cmake"

COPY cmake/android.cmake "${CMAKE_TOOLCHAIN_FILE}"

RUN apt-get update && apt-get install -y --no-install-recommends python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV NDK_VERION="r25c"
ENV ANDROID_API="24"
ENV ANDROID_ARCH="arm"

COPY scripts/build-android-toolchain.sh /scripts/
RUN ./scripts/build-android-toolchain.sh \
    && rm -rf /scripts
