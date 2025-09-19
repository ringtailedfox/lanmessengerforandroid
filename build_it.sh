#!/bin/bash
set -e

if [ -z "$ANDROID_NDK_ROOT" ]; then
  echo "ERROR: ANDROID_NDK_ROOT is not set."
  exit 1
fi

echo "Current working directory: $(pwd)"


# 🧭 Paths and environment
PROJECT_ROOT=~/Downloads/lanmessenger
BUILD_DIR="$PROJECT_ROOT/build-arm64"
ABI="armv8a"
DEPLOYMENT_JSON="$PROJECT_ROOT/android-lmcapp-deployment-settings-${ABI}.json"
QT_CMAKE=/home/user/Qt/Tools/CMake/bin/cmake
QT_ANDROID="/home/user/Qt/6.9.2/android_arm64_v8a"
ANDROID_SDK="/home/user/android/sdk"
ANDROID_NDK="$ANDROID_NDK_ROOT"
ANDROID_PLATFORM="android-30"
BUILD_TOOLS_VERSION="30.0.3"

export QT_DEBUG_FIND_PACKAGE=ON
export CMAKE_PREFIX_PATH=/home/user/Qt/6.9.2/android_arm64_v8a
export Qt6_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6
export Qt6Core_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Core
export Qt6Gui_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Gui
export Qt6Widgets_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Widgets
export Qt6Xml_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Xml
export Qt6Network_DIR=/home/user/Qt/6.9.2/android_arm64_v8a/lib/cmake/Qt6Network


# 🧪 Validate environment
if [ -z "$ANDROID_NDK_ROOT" ]; then
  echo "ERROR: ANDROID_NDK_ROOT is not set."
  exit 1
fi

echo "🔧 Building for ABI: $ABI"
echo "📁 Working directory: $(pwd)"

# 🧼 Clean build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 🏗️ Configure CMake
$QT_CMAKE -G Ninja -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI="arm64-v8a" \
  -DANDROID_PLATFORM="$ANDROID_PLATFORM" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_PREFIX_PATH="$QT_ANDROID" \
  -DQt6_DIR="$QT_ANDROID/lib/cmake/Qt6" \
  -DQt6Core_DIR="$QT_ANDROID/lib/cmake/Qt6Core" \
  -DQt6Gui_DIR="$QT_ANDROID/lib/cmake/Qt6Gui" \
  -DQt6Widgets_DIR="$QT_ANDROID/lib/cmake/Qt6Widgets" \
  -DQt6Xml_DIR="$QT_ANDROID/lib/cmake/Qt6Xml" \
  -DQt6Network_DIR="$QT_ANDROID/lib/cmake/Qt6Network" \
  -DQt6Multimedia_DIR="$QT_ANDROID/lib/cmake/Qt6Multimedia" \
  -DANDROID_PACKAGE_SOURCE_DIR="$PROJECT_ROOT/android"

# 🔨 Build
$QT_CMAKE --build "$BUILD_DIR"

# 🧾 Generate deployment JSON
cat > "$DEPLOYMENT_JSON" <<EOF
{
    "qt": "$QT_ANDROID",
    "sdk": "$ANDROID_SDK",
    "ndk": "$ANDROID_NDK",
    "toolchain-version": "clang",
    "application-binary": "$BUILD_DIR/lmcapp/lmcapp",
    "android-package": "com.lmcapp.chat",
    "android-version-name": "1.0",
    "android-version-code": "1",
    "deployment": {
        "qml": false,
        "resources": [],
        "assets": [],
        "libraries": []
    },
    "android-extra-libs": [],
    "android-extra-plugins": [],
    "target-architecture": "arm64-v8a",
    "qml-imports": [],
    "plugins": [],
    "sdk-build-tools": "$BUILD_TOOLS_VERSION",
    "android-package-source-directory": "$PROJECT_ROOT/android"
}
EOF

# 🚀 Deploy APK
"$QT_ANDROID/bin/androiddeployqt" \
  --input "$DEPLOYMENT_JSON" \
  --output "$BUILD_DIR" \
  --target "$ANDROID_PLATFORM" \
  --verbose

# 📦 Locate APK
APK_PATH="$BUILD_DIR/android-build/build/outputs/apk/debug/android-build-debug.apk"
echo "✅ APK generated: $APK_PATH"

# 🔐 Optional signing
if [ -f "$PROJECT_ROOT/my-release-key.jks" ]; then
  echo "🔐 Signing APK..."
  "$ANDROID_SDK/build-tools/$BUILD_TOOLS_VERSION/apksigner" sign \
    --ks "$PROJECT_ROOT/my-release-key.jks" \
    --out "$PROJECT_ROOT/lmcapp-release-${ABI}.apk" \
    "$APK_PATH"
  echo "✅ Signed APK: $PROJECT_ROOT/lmcapp-release-${ABI}.apk"
fi
