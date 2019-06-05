#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL ${OPENSSL_VERSION} for iOS and OSX that contains code for armv6, armv7, armv7s, arm64, x86_64.

set -e
set -x

export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"

cd "${CXXPODS_BUILD_DIR}"
BASE_PWD="$PWD"
SCRIPT_DIR="$PWD" #cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Setup paths to stuff we need
OPENSSL_VERSION="1.1.0h"

DEVELOPER=$(xcode-select --print-path)

# IPHONEOS_SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)
# IPHONEOS_DEPLOYMENT_VERSION="6.0"
# IPHONEOS_PLATFORM=$(xcrun --sdk iphoneos --show-sdk-platform-path)
# IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)

# IPHONESIMULATOR_PLATFORM=$(xcrun --sdk iphonesimulator --show-sdk-platform-path)
# IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)

OSX_SDK_VERSION=$(xcrun --sdk macosx --show-sdk-version)
OSX_DEPLOYMENT_VERSION="10.8"
OSX_PLATFORM=$(xcrun --sdk macosx --show-sdk-platform-path)
OSX_SDK=$(xcrun --sdk macosx --show-sdk-path)

configure() {
   
   #local ARCH=$2
   local BUILD_DIR=$1
   local SRC_DIR=$2

   echo "Configuring for macOS"

   TARGET=darwin64-x86_64-cc
   COMPILER_ARGS="no-shared"
   
   ${SRC_DIR}/Configure ${TARGET} ${COMPILER_ARGS} --prefix="${CXXPODS_BUILD_ROOT}" &>"${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}.log"

   # if [ "$ARCH" != "x86_64" ]; then
   #    perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' ${SRC_DIR}/crypto/ui/ui_openssl.c
   # fi
}

build() {
   local ARCH=$1
   local SDK=$2
   local BUILD_DIR=$3
   local TYPE=$4

   local SRC_DIR="${BUILD_DIR}/openssl-${OPENSSL_VERSION}-${TYPE}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   echo "Building for ${SDK##*/} ${ARCH} in ${SRC_DIR} with base ${BUILD_DIR}"

   export BUILD_TOOLS="${DEVELOPER}"
   # export CC=clang #
   export CC="${BUILD_TOOLS}/usr/bin/gcc -fembed-bitcode"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift
   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/include/openssl/rsa.h


   configure ${BUILD_DIR} ${SRC_DIR}
   LOG_PATH="${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}.log"
   echo "Building ${LOG_PATH}"
   make -j${CXXPODS_PROC_COUNT} &>${LOG_PATH}
   make -j${CXXPODS_PROC_COUNT} install &>${LOG_PATH}
   cd ${BASE_PWD}

   # Add arch to library
   # if [ -f "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a" ]; then
   #    xcrun lipo "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a" "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libcrypto.a" -create -output "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a"
   #    xcrun lipo "${SCRIPT_DIR}/${TYPE}/lib/libssl.a" "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libssl.a" -create -output "${SCRIPT_DIR}/${TYPE}/lib/libssl.a"
   # else
   #    cp "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libcrypto.a" "${SCRIPT_DIR}/${TYPE}/lib/libcrypto.a"
   #    cp "${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/lib/libssl.a" "${SCRIPT_DIR}/${TYPE}/lib/libssl.a"
   # fi

   # mv ${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/include/openssl/opensslconf.h ${BUILD_DIR}/${OPENSSL_VERSION}-${ARCH}/include/openssl/opensslconf-${ARCH}.h

   #rm -rf "${SRC_DIR}"
}


build_macos() {
   local ARCH=$1
   local BUILD_DIR="$PWD/build"
   if [ ! -e "${BUILD_DIR}" ]; then
      mkdir -p ${BUILD_DIR}
   fi
   

   case "${ARCH}" in
   x86_64) build "x86_64" "${OSX_SDK}" "${BUILD_DIR}" "macos" ;;
   *)
      echo "Unknown ARCH: ${ARCH}"
      exit -1
      ;;
   esac
   
}

# build_macos() {
#    local TMP_DIR=$( mktemp -d )

#    # Clean up whatever was left from our previous build
#    rm -rf ${SCRIPT_DIR}/{macos/include,macos/lib}
#    mkdir -p ${SCRIPT_DIR}/{macos/include,macos/lib}

#    build "x86_64" ${OSX_SDK} ${TMP_DIR} "macos"

#    # Copy headers
#    cp -r ${TMP_DIR}/${OPENSSL_VERSION}-x86_64/include/openssl ${SCRIPT_DIR}/macos/include
#    cp -f ${SCRIPT_DIR}/shim/shim.h ${SCRIPT_DIR}/macos/include/openssl/shim.h

#    cp -f ${TMP_DIR}/${OPENSSL_VERSION}-x86_64/include/openssl/opensslconf-x86_64.h ${SCRIPT_DIR}/macos/include/openssl

#    generate_opensslconfh ${SCRIPT_DIR}/macos/include/openssl/opensslconf.h

#    rm -rf ${TMP_DIR}
# }

# Start

if [ ! -f "${BASE_PWD}/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o ${BASE_PWD}/openssl-${OPENSSL_VERSION}.tar.gz
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o ${BASE_PWD}/openssl-${OPENSSL_VERSION}.tar.gz.sha256
   DIGEST=$(cat ${BASE_PWD}/openssl-${OPENSSL_VERSION}.tar.gz.sha256)
   echo "${DIGEST} ${BASE_PWD}/openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum --check --strict
   rm -f ${BASE_PWD}/openssl-${OPENSSL_VERSION}.tar.gz.sha256
fi

build_macos x86_64
# build_macos

# ${SCRIPT_DIR}/create-framework.sh

echo "all done"
