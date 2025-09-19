#!/bin/bash
set -e

if [ -z "$ANDROID_NDK_ROOT" ]; then
  echo "ERROR: ANDROID_NDK_ROOT is not set."
  exit 1
fi

echo "Current working directory: $(pwd)"

PROJECT_ROOT=~/Downloads/lanmessenger
BUILD_DIR="$PROJECT_ROOT/build-arm64"
QT_CMAKE=/home/user/Qt/Tools/CMake/bin/cmake

export QT_DEBUG_FIND_PACKAGE=ON
export CMAKE_PREFIX_PATH=/home/user/Qt/6.9.2/android_arm64_v8a
export Qt6_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6
export Qt6Core_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Core
export Qt6Gui_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Gui
export Qt6Widgets_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Widgets
export Qt6Xml_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Xml
export Qt6Network_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Network

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

$QT_CMAKE -G Ninja -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI="arm64-v8a" \
  -DANDROID_PLATFORM="android-30" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_PREFIX_PATH="/home/user/Qt/6.9.2/android_arm64_v8a" \
  -DQt6_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6" \
  -DQt6Core_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Core" \
  -DQt6Gui_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Gui" \
  -DQt6Widgets_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Widgets" \
  -DQt6Xml_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Xml" \
  -DQt6Network_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Network" \
  -DQt6Multimedia_DIR="/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Multimedia" \
  -DANDROID_PACKAGE_SOURCE_DIR="$PROJECT_ROOT/android"

$QT_CMAKE --build "$BUILD_DIR"
