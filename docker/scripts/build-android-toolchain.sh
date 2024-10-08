#!/usr/bin/env bash
set -ex

tmp_dir="$(mktemp -d /tmp/android-ndk-XXXXXXXXXXX)"
trap 'rm -rf "${tmp_dir}"' EXIT
cd "${tmp_dir}"

wget -nv "https://dl.google.com/android/repository/android-ndk-${NDK_VERION}-linux.zip"
unzip "android-ndk-${NDK_VERION}-linux.zip" 1>log 2>err
"./android-ndk-${NDK_VERION}/build/tools/make_standalone_toolchain.py" \
  --arch="${ANDROID_ARCH}" \
  --api="${ANDROID_API}" \
  --stl=libc++ \
  --install-dir="${CROSS_ROOT}"

ln -s "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-clang" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-cc"
for i in ar as nm ranlib; do
  ln -s "${CROSS_ROOT}/bin/llvm-${i}" "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-${i}"
done
