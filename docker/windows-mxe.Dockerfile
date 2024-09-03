ARG BASE_TAG=latest
FROM i96751414/cross-compiler-base:${BASE_TAG}

ARG MXE_TARGET

ARG MXE_REV=9f349e0de62a4a68bfc0f13d835a6c685dae9daa
ARG PREFIX=/usr

RUN apt-get update && apt-get install --yes --no-install-recommends \
      autoconf automake autopoint bash bison bzip2 flex g++ g++-multilib gettext git gperf intltool libc6-dev-i386 \
      libgdk-pixbuf2.0-dev libltdl-dev libgl-dev libpcre3-dev libssl-dev libtool-bin libxml-parser-perl lzip make \
      openssl p7zip-full patch perl python3 python3-distutils python3-mako python3-packaging python3-pkg-resources \
      python-is-python3 ruby sed sqlite3 unzip wget xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mxe_src="$(mktemp -d /tmp/mxe-XXXXXXXXXXX)" \
    && wget "https://github.com/mxe/mxe/archive/${MXE_REV}.tar.gz" -qO- | tar -C ${mxe_src} --strip=1 -xz \
    && cd "${mxe_src}" \
    && { \
      echo "MXE_TARGETS := ${MXE_TARGET}"; \
      echo "MXE_USE_CCACHE :="; \
      echo "MXE_PLUGIN_DIRS := plugins/gcc11"; \
      echo "LOCAL_PKG_LIST := cc cmake"; \
      echo ".DEFAULT local-pkg-list:"; \
      echo "local-pkg-list: \$(LOCAL_PKG_LIST)"; \
    } > settings.mk \
    && make "JOBS=$(nproc)" "PREFIX=${PREFIX}" \
    && cd / \
    && rm -rf "${mxe_src}"

ENV CROSS_TRIPLE="${MXE_TARGET}"
ENV CROSS_ROOT="/usr/${CROSS_TRIPLE}"
ENV PATH="${PATH}:${CROSS_ROOT}/bin"
ENV LD_LIBRARY_PATH="${CROSS_ROOT}/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="${CROSS_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
ENV CMAKE_TOOLCHAIN_FILE="${CROSS_ROOT}/share/cmake/mxe-conf.cmake"

ENV AS="/usr/bin/${CROSS_TRIPLE}-as" \
    AR="/usr/bin/${CROSS_TRIPLE}-ar" \
    CC="/usr/bin/${CROSS_TRIPLE}-gcc" \
    CPP="/usr/bin/${CROSS_TRIPLE}-cpp" \
    CXX="/usr/bin/${CROSS_TRIPLE}-g++" \
    LD="/usr/bin/${CROSS_TRIPLE}-ld" \
    FC="/usr/bin/${CROSS_TRIPLE}-gfortran"
