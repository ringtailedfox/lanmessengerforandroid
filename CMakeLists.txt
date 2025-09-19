cmake_minimum_required(VERSION 3.22)
project(LANMessenger)

# I want this thing to compile cleanly, with no FATAL ERRORS, WARNINGS, Deprecated: alerts, and so on... just a good clean proper standards-compilant build t make porting to other OSes like BSD a dream:
# add_compile_options(-Wall -Wextra -Wpedantic -Werror)

# To ensure further strict C++ 17 compliance, we'll set these variables on:
# set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
# set(CMAKE_CXX_EXTENSIONS OFF)

# Let's set which architectures we want to build for, in our case, ARM 32-bit, ARM 64-bit, Intel x86 32-bit and Intel x86 64-bit,respectively:'
if(ANDROID_ABI STREQUAL "armeabi-v7a")
    set(OPENSSL_DIR ${CMAKE_SOURCE_DIR}/openssl-libs/armv7)
elseif(ANDROID_ABI STREQUAL "arm64-v8a")
    set(OPENSSL_DIR ${CMAKE_SOURCE_DIR}/openssl-libs/armv8)
elseif(ANDROID_ABI STREQUAL "x86")
    set(OPENSSL_DIR ${CMAKE_SOURCE_DIR}/openssl-libs/x86)
elseif(ANDROID_ABI STREQUAL "x86_64")
    set(OPENSSL_DIR ${CMAKE_SOURCE_DIR}/openssl-libs/x86_64)
endif()

set_property(DIRECTORY PROPERTY OPENSSL_DIR ${OPENSSL_DIR})

set(LMCAPP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/lmcapp/include)

#include_directories(${OPENSSL_DIR}/include)
#target_link_libraries(lmc
#    ${OPENSSL_DIR}/libcrypto.a
#    ${OPENSSL_DIR}/libssl.a
#)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Qt setup
set(QT_ABI_DIR "android_${ANDROID_ABI}")
set(CMAKE_PREFIX_PATH "/home/user/Qt/6.9.2/${QT_ABI_DIR}")
# set(CMAKE_PREFIX_PATH "/home/user/Qt/6.9.2/android_arm64_v8a")
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

if(NOT DEFINED OPENSSL_DIR)
    message(FATAL_ERROR "Unsupported ANDROID_ABI: ${ANDROID_ABI}")
endif()


# Qt6 Setup Configuration:
set(QT_ABI_DIR "android_${ANDROID_ABI}")
set(CMAKE_PREFIX_PATH "/home/user/Qt/6.9.2/${QT_ABI_DIR}")
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Network Widgets Xml)

# Now add subdirectories
add_subdirectory(lmc)
add_subdirectory(lmcapp)

# Diagnostic messages
message(STATUS "Qt6_DIR is set to: ${Qt6_DIR}")
message(STATUS "CMAKE_PREFIX_PATH is: ${CMAKE_PREFIX_PATH}")
message(STATUS "CMake sees ANDROID_ABI as: ${ANDROID_ABI}")
#if(NOT ANDROID_ABI STREQUAL "arm64-v8a")
#    message(FATAL_ERROR "ABI mismatch: CMake is not respecting your architectah!")
#endif()

message(STATUS "OpenSSL directory: ${OPENSSL_DIR}")
message(STATUS "Qt ABI directory: ${QT_ABI_DIR}")
