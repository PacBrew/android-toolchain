cmake_minimum_required(VERSION 3.6.0)

if (NOT DEFINED ENV{ANDROID_NDK})
    set(ANDROID_NDK /opt/pacbrew/android/android-ndk)
    set(ENV{ANDROID_NDK} ${ANDROID_NDK})
else ()
    set(ANDROID_NDK $ENV{ANDROID_NDK})
endif ()

set(ANDROID_NDK_HOME $ENV{ANDROID_NDK})

if (NOT DEFINED ENV{ANDROID_PREFIX})
    set(ANDROID_PREFIX /opt/pacbrew/android/portlibs/@TRIPLE@)
    set(ENV{ANDROID_PREFIX} ${ANDROID_PREFIX})
else ()
    set(ANDROID_PREFIX $ENV{ANDROID_PREFIX})
endif ()

set(ANDROID_ABI arm64-v8a)
set(CMAKE_ANDROID_ARCH_ABI arm64-v8a)
include(${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_ASM_FLAGS_INIT
  "${CMAKE_ASM_FLAGS_INIT} \
  -D_FORTIFY_SOURCE=2 -pipe -fno-plt -fexceptions --param=ssp-buffer-size=4 \
  -isysroot ${ANDROID_PREFIX} -isystem ${ANDROID_PREFIX}/include -I${ANDROID_PREFIX}/include")
set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} ${CMAKE_ASM_FLAGS_INIT}")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} ${CMAKE_C_FLAGS_INIT}")
set(CMAKE_C_STANDARD_LIBRARIES "-L${ANDROID_PREFIX}/lib ${CMAKE_C_STANDARD_LIBRARIES}")
set(CMAKE_CXX_STANDARD_LIBRARIES "-L${ANDROID_PREFIX}/lib ${CMAKE_CXX_STANDARD_LIBRARIES} ${CMAKE_C_STANDARD_LIBRARIES}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-L${ANDROID_PREFIX}/lib ${CMAKE_EXE_LINKER_FLAGS_INIT} -Wl,-O1,--sort-common,--as-needed")

set(CMAKE_FIND_ROOT_PATH ${ANDROID_PREFIX})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

find_program(PKG_CONFIG_EXECUTABLE NAMES android-pkg-config HINTS "${ANDROID_PREFIX}/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
    message(WARNING "Could not find android-pkg-config: try installing android-pkg-config")
endif ()

