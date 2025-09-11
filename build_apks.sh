#!/bin/bash

set -e

# === CONFIGURATION ===
PROJECT_ROOT=~/Downloads/lanmessenger
OUTPUT_DIR="$PROJECT_ROOT/output_apks"
BUILD_BASE="$PROJECT_ROOT/build"
ANDROID_API_LEVEL=35
ANDROID_ABI=arm64-v8a
ANDROID_PLATFORM=android-35
QT_CMAKE=/home/user/Qt/Tools/CMake/bin/cmake
QT_ANDROID_DEPLOYQT=/home/user/Qt/6.9.2/android_arm64_v8a/bin/androiddeployqt

mkdir -p "$OUTPUT_DIR"

# === Map ABI and NDK triple ===
function map_abi() {
    case "$1" in
        armeabi-v7a) QT_ABI_DIR=android_armv7 ;;
        arm64-v8a) QT_ABI_DIR=android_arm64_v8a ;;
        x86) QT_ABI_DIR=android_x86 ;;
        x86_64) QT_ABI_DIR=android_x86_64 ;;
    esac
}

function map_ndk_triple() {
    case "$1" in
        armeabi-v7a) NDK_TRIPLE=arm-linux-androideabi ;;
        arm64-v8a) NDK_TRIPLE=aarch64-linux-android ;;
        x86) NDK_TRIPLE=i686-linux-android ;;
        x86_64) NDK_TRIPLE=x86_64-linux-android ;;
    esac
}

# === Build for ABI ===
for ABI in $ANDROID_ABI; do
    echo "🔧 Building for $ABI..."
    BUILD_DIR="$BUILD_BASE/$ABI"
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    map_abi "$ABI"
    map_ndk_triple "$ABI"

    "$QT_CMAKE" -G Ninja -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$PROJECT_ROOT/android.toolchain.cmake" \
        -DANDROID_API_LEVEL=$ANDROID_API_LEVEL \
        -DANDROID_ABI=$ABI \
        -DANDROID_PLATFORM=$ANDROID_PLATFORM \
        -DCMAKE_PREFIX_PATH="/home/user/Qt/6.9.2/$QT_ABI_DIR/lib/cmake" \
        -DQt6_DIR="/home/user/Qt/6.9.2/$QT_ABI_DIR/lib/cmake/Qt6" \
        -DANDROID_NDK_ROOT="$ANDROID_NDK_ROOT" \
        -DNDK_TRIPLE=$NDK_TRIPLE

    "$QT_CMAKE" --build "$BUILD_DIR"

    "$QT_ANDROID_DEPLOYQT" --input "$BUILD_DIR/android-libLANMessengerForAndroid.so-deployment-settings.json" \
                           --output "$BUILD_DIR/android-build" \
                           --apk --verbose

    cp "$BUILD_DIR/android-build/build/outputs/apk/debug/"*.apk "$OUTPUT_DIR/LANMessenger-$ABI.apk"
    echo "✅ Build succeeded for $ABI"
done
