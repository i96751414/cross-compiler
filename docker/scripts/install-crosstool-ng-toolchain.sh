#!/usr/bin/env bash
set -eo pipefail

# Our base directory is the current working directory. All local artifacts will
# be generated underneath of here.
ROOT=$(pwd)
REV=crosstool-ng-1.23.0
UPGRADE=false

function usage() {
  cat <<EOF
Usage: $(basename "${0}") -c <CONFIG_PATH> [OPTIONS]

This script operates in the current working directory. It downloads
"crosstool-ng", installs the base package, and then configures and installs
a toolchain based on the supplied prefix and configuration.
More info at http://crosstool-ng.github.io/docs/

required arguments:
  -c <config>   Configuration path
  -r <rev>      Crosstool-ng revision (default: ${REV})

optional arguments:
  -p <prefix>   Installation prefix
  -u            Upgrade the provided config before installing the toolchain
  -h            Show this message
EOF
  exit 1
}

while getopts "p:c:r:uh" o; do
  case "${o}" in
  p) CT_PREFIX=$(readlink -f "${OPTARG}") ;;
  c) CONFIG_PATH=$(readlink -f "${OPTARG}") ;;
  r) REV=${OPTARG} ;;
  u) UPGRADE=true ;;
  *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${CONFIG_PATH}" ] || [ ! -f "${CONFIG_PATH}" ]; then
  echo "ERROR: Missing config path (-c)."
  usage
fi

set -x

##
# Build "crosstool-ng".
##

CTNG=${ROOT}/ct-ng
mkdir -p "${CTNG}"

# Download and install the "crosstool-ng" source.
CTNG_SRC="${CTNG}/crosstool-ng-src"
mkdir -p "${CTNG_SRC}"
curl -sS -L "https://github.com/crosstool-ng/crosstool-ng/archive/${REV}.tar.gz" | tar -C "${CTNG_SRC}" --strip=1 -xz
cd "${CTNG_SRC}"

# Fix for expat in old crosstool-ng versions
# shellcheck disable=SC2016
OUTDATED_EXPAT='http://downloads.sourceforge.net/project/expat/expat/${CT_EXPAT_VERSION}'
# shellcheck disable=SC2016
UPDATED_EXPAT='https://github.com/libexpat/libexpat/releases/download/R_${CT_EXPAT_VERSION//./_}'
if [ -f "scripts/build/companion_libs/210-expat.sh" ]; then
  sed -i "s|${OUTDATED_EXPAT}|${UPDATED_EXPAT}|" "scripts/build/companion_libs/210-expat.sh"
fi

# Bootstrap and install the tool.
./bootstrap
./configure --prefix "${CTNG}"
make -j"$(nproc)"
make install
rm -rf "$(pwd)"

##
# Use "crosstool-ng" to build the toolchain.
##

# Override installation prefix, since we want to define it externally.
if [ -n "${CT_PREFIX}" ]; then
  export CT_PREFIX
fi

# Allow installation as root, since we aren't really worried about system
# damage b/c we're running in a container and this saves us the trouble of
# having to generate a crosstool user.
export CT_ALLOW_BUILD_AS_ROOT_SURE=1

# Create our build directory and copy our configuration into it.
BUILD="${ROOT}/toolchain"
mkdir -p "${BUILD}"
cd "${BUILD}"
cp "${CONFIG_PATH}" "${BUILD}/.config"

# As mentioned in ct-ng config, need to unset LD_LIBRARY_PATH.
unset LD_LIBRARY_PATH

if [ "${UPGRADE}" == "true" ]; then
  "${CTNG}/bin/ct-ng" upgradeconfig
fi

"${CTNG}/bin/ct-ng" build."$(nproc)"
