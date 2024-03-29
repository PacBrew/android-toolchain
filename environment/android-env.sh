#!/bin/sh

# Useful link to keep track of latest API changes:
#
# https://developer.android.com/ndk/downloads/revision_history

_android_arch=$1

if [ -z "${_android_arch}" ]; then
    _android_arch=aarch64
fi

# Minimum Android platform based on:
#
# http://gs.statcounter.com/os-version-market-share/android/mobile-tablet/worldwide
if [ -z "${ANDROID_MINIMUM_PLATFORM}" ]; then
    export ANDROID_MINIMUM_PLATFORM=24
fi

if [ -z "${ANDROID_HOME}" ]; then
    export ANDROID_HOME=/opt/pacbrew/android/android-sdk
fi

if [ -z "${ANDROID_SDK}" ]; then
    export ANDROID_SDK=/opt/pacbrew/android/android-sdk
fi

if [ -z "${ANDROID_SDK_ROOT}" ]; then
    export ANDROID_SDK_ROOT=/opt/pacbrew/android/android-sdk
fi

if [ -z "${ANDROID_NDK}" ]; then
    export ANDROID_NDK=/opt/pacbrew/android/android-ndk
fi

if [ -z "${ANDROID_NDK_HOME}" ]; then
    export ANDROID_NDK_HOME=/opt/pacbrew/android/android-ndk
fi

get_last() {
    ls $1 | sort -V | tail -n 1
}

if [ -z "${ANDROID_BUILD_TOOLS_REVISION}" ]; then
    export ANDROID_BUILD_TOOLS_REVISION=$(get_last ${ANDROID_HOME}/build-tools)
fi

if [ -z "${ANDROID_API_VERSION}" ]; then
    export ANDROID_API_VERSION=android-$ANDROID_MINIMUM_PLATFORM
fi

if [ -z "${ANDROID_NDK_PLATFORM}" ]; then
    export ANDROID_NDK_PLATFORM=android-$ANDROID_MINIMUM_PLATFORM
fi

export ANDROID_SDK_PLATFORM=${ANDROID_HOME}/platforms/$ANDROID_API_VERSION
export ANDROID_PLATFORM=${ANDROID_NDK_HOME}/platforms/$ANDROID_NDK_PLATFORM
export ANDROID_TOOLCHAIN=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64
export ANDROID_SYSROOT=${ANDROID_TOOLCHAIN}/sysroot
export ANDROID_CROSS_PREFIX=$ANDROID_TOOLCHAIN/bin

case "$_android_arch" in
    aarch64)
        export ANDROID_TOOLS_COMPILER_PREFIX=${ANDROID_CROSS_PREFIX}/aarch64-linux-android${ANDROID_MINIMUM_PLATFORM}-
        export ANDROID_ABI=arm64-v8a
        ;;
    armv7a)
        export ANDROID_TOOLS_COMPILER_PREFIX=${ANDROID_CROSS_PREFIX}/armv7a-linux-androideabi${ANDROID_MINIMUM_PLATFORM}-
        export ANDROID_ABI=armeabi-v7a
        ;;
    x86)
        export ANDROID_TOOLS_COMPILER_PREFIX=${ANDROID_CROSS_PREFIX}/i686-linux-android${ANDROID_MINIMUM_PLATFORM}-
        export ANDROID_ABI=x86
        ;;
    x86_64)
        export ANDROID_TOOLS_COMPILER_PREFIX=${ANDROID_CROSS_PREFIX}/x86_64-linux-android${ANDROID_MINIMUM_PLATFORM}-
        export ANDROID_ABI=x86_64
        ;;
esac

export ANDROID_CC=${ANDROID_TOOLS_COMPILER_PREFIX}clang
export ANDROID_CXX=${ANDROID_TOOLS_COMPILER_PREFIX}clang++
export ANDROID_TOOLS_PREFIX=${ANDROID_CROSS_PREFIX}/llvm-
export ANDROID_AR=${ANDROID_TOOLS_PREFIX}ar
export ANDROID_AS=${ANDROID_TOOLS_PREFIX}as
export ANDROID_NM=${ANDROID_TOOLS_PREFIX}nm
export ANDROID_RANLIB=${ANDROID_TOOLS_PREFIX}ranlib
export ANDROID_STRIP=${ANDROID_TOOLS_PREFIX}strip
export ANDROID_OBJCOPY=${ANDROID_TOOLS_PREFIX}objcopy
export ANDROID_LD=${ANDROID_CROSS_PREFIX}/ld
export ANDROID_PREFIX=/opt/pacbrew/android/portlibs/${_android_arch}
export ANDROID_PREFIX_USR=${ANDROID_PREFIX}/usr
export ANDROID_PREFIX_BIN=${ANDROID_PREFIX}/bin
export ANDROID_PREFIX_INCLUDE=${ANDROID_PREFIX}/include
export ANDROID_PREFIX_LIB=${ANDROID_PREFIX}/lib
export ANDROID_PREFIX_ETC=${ANDROID_PREFIX}/etc
export ANDROID_PREFIX_SHARE=${ANDROID_PREFIX}/share

export CC=${ANDROID_CC}
export CXX=${ANDROID_CXX}
export AS=${ANDROID_AS}
export AR=${ANDROID_AR}
export NM=${ANDROID_NM}
export LD=${ANDROID_LD}
export RANLIB=${ANDROID_RANLIB}
export STRIP=${ANDROID_STRIP}
export OBJCOPY=${ANDROID_OBJCOPY}

default_android_pp_flags="-I${ANDROID_PREFIX_INCLUDE} -fPIC -D_FORTIFY_SOURCE=2"
default_android_compiler_flags="-I${ANDROID_PREFIX_INCLUDE} -O2 -fPIC -pipe -fno-plt -fexceptions --param=ssp-buffer-size=4"
default_android_linker_flags="-L${ANDROID_PREFIX_LIB} -Wl,-O1,--sort-common,--as-needed"

case "$_android_arch" in
    aarch64)
        export default_android_pp_flags="${default_android_pp_flags} -march=armv8-a"
        export default_android_compiler_flags="${default_android_compiler_flags} -march=armv8-a"
        ;;
    armv7a)
        export default_android_pp_flags="${default_android_pp_flags} -mtune=cortex-a9 -march=armv7-a -mfpu=neon -mfloat-abi=softfp"
        export default_android_compiler_flags="${default_android_compiler_flags} -mtune=cortex-a9 -march=armv7-a -mfpu=neon -mfloat-abi=softfp"
        ;;
    x86_64)
        export default_android_pp_flags="${default_android_pp_flags} -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=x86-64"
        export default_android_compiler_flags="${default_android_compiler_flags} -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=x86-64"
        ;;
esac
export CPPFLAGS="${ANDROID_CPPFLAGS:-$default_android_pp_flags $CPPFLAGS}"
export CFLAGS="${ANDROID_CFLAGS:-$default_android_compiler_flags $CFLAGS}"
export CXXFLAGS="${ANDROID_CXXFLAGS:-$default_android_compiler_flags $CXXFLAGS}"
export LDFLAGS="${ANDROID_LDFLAGS:-$default_android_linker_flags $LDFLAGS}"

export ANDROID_PKGCONFIG=${ANDROID_PREFIX_BIN}/${_android_arch}-linux-android-pkg-config
export PKG_CONFIG=${ANDROID_PREFIX_BIN}/${_android_arch}-linux-android-pkg-config
export PKG_CONFIG_LIBDIR=${ANDROID_PREFIX_LIB}/pkgconfig:${ANDROID_PREFIX_SHARE}/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${ANDROID_PREFIX}

# paths
export PATH=$ANDROID_CROSS_PREFIX:$ANDROID_PREFIX_BIN:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH

ndk_version() {
    grep 'Pkg.Revision' ${ANDROID_NDK_HOME}/source.properties | awk '{print $3}'
}

check_ndk_version_ge_than() {
    version=$1
    ndk_ver=$(ndk_version)

    if [ "${version}" = "${ndk_ver}" ]; then
        return 0
    fi

    older_ver=$(printf "${version}\n${ndk_ver}" | sort -V | head -n 1)

    if [ "${older_ver}" = "${ndk_ver}" ]; then
        echo "ERROR: NDK version >= $version required."

        return -1
    fi

    return 0
}

check_android_platform() {
    if [ ! -e "${ANDROID_SDK_PLATFORM}/source.properties" ]; then
        echo "ERROR: Please, install android-platform-${ANDROID_MINIMUM_PLATFORM}."

        return -1
    fi

    return 0
}
