#!/bin/bash

source /opt/pacbrew/android/android-env.sh @TRIPLE@

target=@TRIPLE@-linux-android

./configure \
    --host=${target} \
    --target=${target} \
    --build=${CHOST} \
    --prefix=${ANDROID_PREFIX} \
    --libdir=${ANDROID_PREFIX_LIB} \
    --includedir=${ANDROID_PREFIX_INCLUDE} \
    --disable-shared \
    --enable-static \
    "$@"
