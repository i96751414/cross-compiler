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
