#!/bin/bash -e

toupper(){
    echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

tolower(){
    echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}


if [ "${CMAKE_SYSROOT}" != "" ]; then
    echo "Using CMake Sysroot: ${CMAKE_SYSROOT}"

    SYSROOT=${CMAKE_SYSROOT}
    CROSS_COMPILING=1
    CROSS_PREFIX=
    CROSS_SUFFIX=
    ARCH=
    HOST_OS=$(tolower $(uname -s))
    TARGET_OS=${HOST_OS}
    ANDROID_ARCH=
    
    CC=${CMAKE_C_COMPILER}
    CXX=${CMAKE_CXX_COMPILER}
    CROSS_PREFIX=${CMAKE_CROSS_PREFIX}
    CROSS_SUFFIX=${CMAKE_CROSS_SUFFIX}
    TARGET_OS=$(tolower ${CMAKE_SYSTEM_NAME})
    
    if [ "${TARGET_OS}" = "android" ]; then
        ANDROID=1
        ARCH=${ANDROID_ABI}
        ANDROID_ARCH=${ARCH}
        case "${ARCH}" in
            arm64-v8a) 
                ARCH=aarch64
                ANDROID_ARCH=arm64
                ;;
            armeabi-v7a)
                ARM=arm
                ANDROID_ARCH=arm 
                ;;
        esac

        
        CC=${ANDROID_C_COMPILER}
        CXX=${ANDROID_CXX_COMPILER}
        if [ "${ANDROID_TOOLCHAIN_PREFIX}" != "" ]; then
            CROSS_PREFIX=${ANDROID_TOOLCHAIN_PREFIX}
            CC=${ANDROID_TOOLCHAIN_PREFIX}gcc
            CXX=${ANDROID_TOOLCHAIN_PREFIX}g++
        fi
    fi
else
    echo "Host compile"
fi

# NORMAL, COMMON OPTIONS

OPTS="--incdir=${CXXPODS_BUILD_INCLUDE} \
    --libdir=${CXXPODS_BUILD_LIB} "
    
# CHECK IF CROSS-COMPILING
if [ "${CROSS_COMPILING}" = "1" ]; then
    CFLAGS="-Ofast"

    for f in "libavcodec/hevc_mvs.c" "libavcodec/aaccoder.c" "libavcodec/opus_pvq.c";do sed -i -e 's/B0/b0/g' "$f"; done

    echo "Cross-Compiling: ${ARCH}"
    echo "SYSROOT=${CMAKE_SYSROOT}"

    if [ "${ARCH}" = "x86" ];then
        OPTS="${OPTS} --disable-asm"
    fi

    OPTS="${OPTS} \
    --disable-shared \
    --enable-static \
    --enable-pic \
    --enable-pthreads \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-debug \
    --enable-decoder=h264 \
    --enable-decoder=hevc \
    --enable-parser=h264 \
    --enable-hardcoded-tables \
    --enable-parser=hevc \
    --enable-demuxer=h264 \
    --enable-demuxer=hevc \
    --enable-gpl \
    --enable-nonfree \
    --target-os=${TARGET_OS} \
    --enable-cross-compile \
    --arch=${ARCH} \
    --cross-prefix=${CROSS_PREFIX} \
    --cc=${CC} \
    --nm=${CROSS_PREFIX}nm \
    --sysroot=${SYSROOT} \
     --cxx=${CXX} \
     --strip=${CROSS_PREFIX}strip \
     --ar=${CROSS_PREFIX}ar \
     --as=${CROSS_PREFIX}gcc \
     --extra-libs=-lgcc \
    --disable-programs"
  
    # ANDROID SPECIFIC
    if [ "${ANDROID}" == "1" ]; then
        ANDROID_PLATFORM_ROOT=${ANDROID_NDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL:-27}/arch-${ANDROID_ARCH}
        ANDROID_PLATFORM_PATH=${ANDROID_SYSTEM_LIBRARY_PATH}

        CFLAGS=" ${CFLAGS} -fPIC -I${ANDROID_PLATFORM_ROOT}/ -I${CMAKE_SYSROOT}/usr/include -I${CMAKE_SYSROOT}/usr/include/${ANDROID_HEADER_TRIPLE} -I${ANDROID_PLATFORM_ROOT}/include -DANDROID -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums"
        if [ "${ARCH}" = "aarch64" ];then
            EXTRA_LD="-L${ANDROID_PLATFORM_ROOT}/usr/lib64"
        fi
        LDFLAGS="${LDFLAGS} -Wl,-rpath-link=${ANDROID_PLATFORM_ROOT}/usr/lib ${EXTRA_LD} -L${ANDROID_PLATFORM_ROOT}/usr/lib  -L${CXXPODS_BUILD_LIB} -nostdlib -lm -lc -ldl"
        
        echo "Platform path: ${ANDROID_PLATFORM_PATH}"
        
        LDFLAGS=" ${LDFLAGS} -llog"
        OPTS="${OPTS} --enable-jni \
            --enable-mediacodec \
            --enable-decoder=h264_mediacodec \
            --enable-hwaccel=hevc_mediacodec \
            --enable-decoder=hevc_mediacodec "
    fi
fi

echo "ENVIRONMENT FOR CONFIGURE"
env 

./configure ${OPTS} ${FFMPEG_OPTS} --extra-cflags="${CFLAGS}" --extra-cxxflags="${CFLAGS}" --extra-ldflags="${LDFLAGS}"