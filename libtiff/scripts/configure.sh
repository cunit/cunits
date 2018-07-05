#!/bin/bash -e

toupper(){
    echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

tolower(){
    echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}


CC=$(which cc)
CXX=$(which cpp)
CROSS_COMPILING=
SYSROOT=
CROSS_PREFIX=
CROSS_SUFFIX=
ARCH=
HOST_OS=$(tolower $(uname -s))
TARGET_OS=${HOST_OS}
if [ "${CMAKE_SYSROOT}" != "" ]; then
    CROSS_COMPILING=1
    CC=${CMAKE_C_COMPILER}
    CXX=${CMAKE_CXX_COMPILER}
    CROSS_PREFIX=${CMAKE_CROSS_PREFIX}
    CROSS_SUFFIX=${CMAKE_CROSS_SUFFIX}
    TARGET_OS=$(tolower ${CMAKE_SYSTEM_NAME})
    ARCH=${CMAKE_SYSTEM_PROCESSOR}
fi

CFLAGS="-Ofast"
OPTS="--includedir=${CUNIT_BUILD_INCLUDE} \
    --libdir=${CUNIT_BUILD_LIB} \
    --enable-static \
    --with-pic \
    --disable-lzma"
    

if [ "${CROSS_COMPILING}" == "1" ]; then
    #
    
    OPTS="${OPTS} --with-sysroot=${CMAKE_SYSROOT} --host=linux"
    # \
    # --extra-libs=-lgcc \
    # --arch=${ARCH} \
    # --cross-prefix=${CROSS_PREFIX} \
    # --nm=${CROSS_PREFIX}nm \
    

    LDFLAGS="${LDFLAGS} -Wl,-rpath-link=${CUNIT_BUILD_LIB} -L${CUNIT_BUILD_LIB} -nostdlib -lc -lm -ldl"
    

fi
export CFLAGS="${CFLAGS}"
export LDFLAGS="${LDFLAGS}"
./configure ${OPTS}  