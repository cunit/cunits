#!/bin/bash -e

toupper(){
    echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

tolower(){
    echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}

for f in "libavcodec/hevc_mvs.c" "libavcodec/aaccoder.c" "libavcodec/opus_pvq.c";do sed -i -e 's/B0/b0/g' "$f"; done

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
    echo "CROSS COMPILING"
    CROSS_COMPILING=1
    CC=${CMAKE_C_COMPILER}
    CXX=${CMAKE_CXX_COMPILER}
    CROSS_PREFIX=${CMAKE_CROSS_PREFIX}
    CROSS_SUFFIX=${CMAKE_CROSS_SUFFIX}
    TARGET_OS=$(tolower ${CMAKE_SYSTEM_NAME})
    ARCH=${CMAKE_SYSTEM_PROCESSOR}
fi

CFLAGS="-Ofast"
OPTS="--incdir=${CUNIT_BUILD_INCLUDE} \
    --libdir=${CUNIT_BUILD_LIB} \
    --enable-static \
    --enable-pic \
    --cc=${CC} \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-debug \
    --enable-decoder=h264 \
    --enable-decoder=h264_mediacodec \
    --enable-decoder=hevc \
    --enable-hwaccel=hevc_mediacodec \
    --enable-decoder=hevc_mediacodec \
    --enable-parser=h264 \
    --enable-parser=hevc \
    --enable-demuxer=h264 \
    --enable-demuxer=hevc \
    --enable-demuxer=mov"

if [ "${CROSS_COMPILING}" == "1" ]; then
    #
    
    OPTS="${OPTS} \
    --target-os=${TARGET_OS} \
    --enable-cross-compile \
    --extra-libs=-lgcc \
    --arch=${ARCH} \
    --cross-prefix=${CROSS_PREFIX} \
    --nm=${CROSS_PREFIX}nm \
    --sysroot=${SYSROOT}" 

    LDFLAGS="${LDFLAGS} -Wl,-rpath-link=${CUNIT_BUILD_LIB} -L${CUNIT_BUILD_LIB} -nostdlib -lc -lm -ldl"
    
    if [ "${TARGET_OS}" == "android" ]; then
        LDFLAGS="${LDFLAGS} -llog"
        OPTS="${OPTS} --enable-jni \
            --enable-mediacodec"
    fi

fi

./configure ${OPTS} --extra-cflags="${CFLAGS}" --extra-ldflags="${LDFLAGS}"