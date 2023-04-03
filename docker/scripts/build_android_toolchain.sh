#!/usr/bin/env bash

set -ex
cd /tmp
wget -nv "https://dl.google.com/android/repository/android-ndk-${NDK_VERION}-linux.zip"
unzip "android-ndk-${NDK_VERION}-linux.zip" 1>log 2>err
"./android-ndk-${NDK_VERION}/build/tools/make_standalone_toolchain.py" \
  --arch="${ANDROID_ARCH}" \
  --api="${ANDROID_API}" \
  --stl=libc++ \
  --install-dir="${CROSS_ROOT}"
cd / && rm -rf /tmp/*

ln -s "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-clang" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cc"
for i in ar as nm ranlib; do
  ln -s "${CROSS_ROOT}/bin/llvm-${i}" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-${i}"
done
