set(CMAKE_SYSTEM_NAME Android)
# Force ABI and platform early
if(NOT DEFINED ANDROID_ABI)
    set(ANDROID_ABI arm64-v8a)
endif()
set(NDK_TRIPLE aarch64-linux-android CACHE STRING "NDK triple")
message(STATUS "Toolchain sees ANDROID_ABI as: ${ANDROID_ABI}")

if(NOT DEFINED ANDROID_API_LEVEL)
    set(ANDROID_API_LEVEL 35)
endif()

set(CMAKE_SYSTEM_VERSION ${ANDROID_API_LEVEL})
set(CMAKE_ANDROID_API ${ANDROID_API_LEVEL})

# Set platform string for NDK sysroot
set(ANDROID_PLATFORM android-${ANDROID_API_LEVEL})
set(NDK_TRIPLE "aarch64-linux-android")
set(NDK_TRIPLE "${NDK_TRIPLE}" CACHE STRING "NDK triple")
set(ANDROID_NDK_ROOT CACHE PATH "Android NDK root")

message(STATUS "Using Android ABI: ${ANDROID_ABI}")
message(STATUS "Using Android API level: ${ANDROID_API_LEVEL}")
message(STATUS "Using Android Platform: ${ANDROID_PLATFORM}")
message(STATUS "Using NDK triple: ${NDK_TRIPLE}")

# Host detection
if(WIN32)
    set(NDK_HOST windows-x86_64)
elseif(APPLE)
    set(NDK_HOST darwin-x86_64)
elseif(UNIX)
    set(NDK_HOST linux-x86_64)
endif()

# Compiler selection
set(CMAKE_C_COMPILER "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${NDK_HOST}/bin/${NDK_TRIPLE}${ANDROID_API_LEVEL}-clang")
set(CMAKE_CXX_COMPILER "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${NDK_HOST}/bin/${NDK_TRIPLE}${ANDROID_API_LEVEL}-clang++")
