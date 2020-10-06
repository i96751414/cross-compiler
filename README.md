cross-compiler [![Build Status](https://github.com/i96751414/cross-compiler/workflows/build/badge.svg)](https://github.com/i96751414/cross-compiler/actions)
==============

C/C++ Cross compiling environment containers

This has been designed to run `libtorrent-go` cross compilation and is not meant to be perfect nor minimal. Adapt as required.

## Overview

### Environment variables

- CROSS_TRIPLE
- CROSS_ROOT
- LD_LIBRARY_PATH
- PKG_CONFIG_PATH

Also adds CROSS_ROOT/bin in your PATH.

### Installed packages

Based on Debian Stretch:
- bash
- curl
- wget
- pkg-config
- build-essential
- make
- automake
- autogen
- libtool
- libpcre3-dev
- bison
- yodl
- tar
- xz-utils
- bzip2
- gzip
- unzip
- file
- rsync
- sed
- upx

And a selection of platform specific packages (see below).

### Platforms built

- android-arm (android-ndk-r20 with api 21, clang)
- android-arm64 (android-ndk-r20 with api 21, clang)
- android-x64 (android-ndk-r20 with api 21, clang)
- android-x86 (android-ndk-r20 with api 21, clang)
- darwin-x64 (clang-4.0, llvm-4.0-dev, libtool, libxml2-dev, uuid-dev, libssl-dev patch make cpio)
- linux-arm (gcc-4.8-arm-linux-gnueabihf with hardfp support for RaspberryPi)
- linux-armv7 (gcc-4.9.4 glibc-2.23 binutils-2.28 kernel-4.10.8 crosstool-ng)
- linux-arm64 (gcc-8.3.0 glibc-2.27 binutils-2.28 kernel-4.10.8 crosstool-ng)
- linux-x64
- linux-x86 (gcc-multilib, g++-multilib)
- windows-x64 (mingw-w64)
- windows-x86 (mingw-w64)

## Building

Either build all images with:

    make

Or selectively build platforms:

    make darwin-x64
