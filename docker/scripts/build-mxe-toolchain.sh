#!/usr/bin/env bash
set -eo pipefail

: "${PREFIX=usr/}"
: "${MXE_REV=9f349e0de62a4a68bfc0f13d835a6c685dae9daa}"
: "${MXE_TARGET_ARCH=x86_64}"
: "${MXE_TARGET_LINK=static}"
: "${MXE_TARGET_THREAD=win32}"

function invalidOpt() {
  echo "Invalid option/argument provided: $1"
  usage 1
}

function validateNotEmpty() {
  if [ -z "${1}" ]; then
    echo "${2} parameter must contain a not empty value"
    usage 1
  fi
}

function usage() {
  cat <<EOF
Usage: $(basename "${0}") [OPTIONS]

Script for building and install MinGW-w64 toolchain using MXE.

optional arguments:
  -p, --prefix PREFIX    The toolchain prefix (default: usr/)
  -r, --rev REV          The MXE revision
  -a, --arch ARCH        The toolchain architecture. Must be either x86_64 or i686 (default: x86_64)
  -l, --link LINK        The linking type. Must be either static or shared (default: static)
  --posix                Use POSIX threading libraries instead of Win32
  --install-dependencies Install MXE dependencies
  -h, --help             Show this message

EOF
  exit "$1"
}

while [ $# -gt 0 ]; do
  case "$1" in
  --) shift; break ;;
  -p | --prefix)  validateNotEmpty "$2" "$1"; shift; PREFIX="$1" ;;
  -r | --rev) validateNotEmpty "$2" "$1"; shift; MXE_REV="$1" ;;
  -a | --arch) validateNotEmpty "$2" "$1"; shift; MXE_TARGET_ARCH="$1" ;;
  -l | --link) validateNotEmpty "$2" "$1"; shift; MXE_TARGET_LINK="$1" ;;
  --posix) MXE_TARGET_THREAD=posix ;;
  --install-dependencies) MXE_INSTALL_DEPENDENCIES=true ;;
  -h | --help) usage 0 ;;
  -*) invalidOpt "$1" ;;
  *) break ;;
  esac
  shift
done

if [ $# -gt 0 ]; then
  echo "No positional arguments expected"
  usage 1
fi

if [ "${MXE_TARGET_ARCH}" != x86_64 ] && [ "${MXE_TARGET_ARCH}" != i686 ]; then
  echo "Target arch (MXE_TARGET_ARCH) must be either x86_64 or i686"
  usage 1
fi

if [ "${MXE_TARGET_LINK}" != static ] && [ "${MXE_TARGET_LINK}" != shared ]; then
  echo "Target link (MXE_TARGET_LINK) must be either static or shared"
  usage 1
fi

case "${MXE_TARGET_THREAD}" in
posix) MXE_TARGET_THREAD=".${MXE_TARGET_THREAD}" ;;
win32) MXE_TARGET_THREAD= ;;
*) echo "Target thread (MXE_TARGET_THREAD) must be either win32 or posix." && usage 1
esac

if [ "${MXE_INSTALL_DEPENDENCIES}" = true ]; then
  echo "- Installing MXE dependencies"
  # According to MXE requirements (https://mxe.cc/#requirements)
  apt-get update && apt-get install --yes --no-install-recommends \
      autoconf automake autopoint bash bison bzip2 flex g++ g++-multilib gettext git gperf intltool libc6-dev-i386 \
      libgdk-pixbuf2.0-dev libltdl-dev libgl-dev libpcre3-dev libssl-dev libtool-bin libxml-parser-perl lzip make \
      openssl p7zip-full patch perl python3 python3-distutils python3-mako python3-packaging python3-pkg-resources \
      python-is-python3 ruby sed sqlite3 unzip wget xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
fi

target="${MXE_TARGET_ARCH}-w64-mingw32.${MXE_TARGET_LINK}${MXE_TARGET_THREAD}"
mxe_src="$(mktemp -d /tmp/mxe-XXXXXXXXXXX)"
trap 'rm -rf "${mxe_src}"' EXIT
cd "${mxe_src}"

echo "- Downloading MXE"
wget "https://github.com/mxe/mxe/archive/${MXE_REV}.tar.gz" -qO- | tar -C "${mxe_src}" --strip=1 -xz

echo "- Creating settings.mk"
cat <<EOF > settings.mk
MXE_TARGETS := ${target}
MXE_USE_CCACHE :=
MXE_PLUGIN_DIRS := plugins/gcc11
LOCAL_PKG_LIST := cc cmake
.DEFAULT local-pkg-list:
local-pkg-list: \$(LOCAL_PKG_LIST)
EOF

echo "- Building MXE toolchain (${target})"
make "JOBS=$(nproc)" "PREFIX=${PREFIX}"
echo "- MXE toolchain (${target}) built to ${PREFIX}"