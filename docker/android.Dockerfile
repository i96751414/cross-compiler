ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ARG CROSS_TRIPLE
ARG ANDROID_ARCH
ARG SYSTEM_PROCESSOR
ARG ANDROID_ARCH_ABI

ARG NDK_VERSION="r25c"
ARG ANDROID_API="24"

ENV CROSS_TRIPLE="${CROSS_TRIPLE}"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV ANDROID_NDK="${CROSS_ROOT}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"

ENV SYSTEM_PROCESSOR="${SYSTEM_PROCESSOR}"
ENV ANDROID_ARCH_ABI="${ANDROID_ARCH_ABI}"
ENV CMAKE_TOOLCHAIN_FILE="/home/android.cmake"

COPY cmake/android.cmake "${CMAKE_TOOLCHAIN_FILE}"

RUN apt-get update && apt-get install -y --no-install-recommends python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp \
    && wget -nv "https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip" \
    && unzip "android-ndk-${NDK_VERSION}-linux.zip" 1>log 2>err \
    && "./android-ndk-${NDK_VERSION}/build/tools/make_standalone_toolchain.py" \
      --arch="${ANDROID_ARCH}" \
      --api="${ANDROID_API}" \
      --stl=libc++ \
      --install-dir="${CROSS_ROOT}" \
    && rm -rf /tmp/*

RUN ln -s "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-clang" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cc" \
    && for i in ar as nm ranlib; do \
      ln -s "${CROSS_ROOT}/bin/llvm-${i}" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-${i}"; \
    done

ENV AS="${CROSS_ROOT}/bin/llvm-as" \
    AR="${CROSS_ROOT}/bin/llvm-ar" \
    CC="${CROSS_ROOT}/bin/clang" \
    CXX="${CROSS_ROOT}/bin/clang++" \
    LD="${CROSS_ROOT}/bin/ld"