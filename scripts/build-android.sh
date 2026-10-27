#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export JAVA_HOME="${JAVA_HOME:-$HOME/development/jdk-21}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export NDK_HOME="${NDK_HOME:-$ANDROID_HOME/ndk/28.2.13676358}"
export PATH="$HOME/.cargo/bin:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"

VERSION="$(node -p "require('./package.json').version")"
KEYSTORE="$HOME/.android/debug.keystore"
APKSIGNER="$ANDROID_HOME/build-tools/36.0.0/apksigner"

npm run tauri android build --apk

UNSIGNED="$(find "$ROOT/src-tauri/gen/android/app/build/outputs/apk" -name '*-unsigned.apk' | head -n 1)"
if [[ -z "$UNSIGNED" ]]; then
  echo "No unsigned APK found. Did the build finish?" >&2
  exit 1
fi

if [[ ! -f "$KEYSTORE" ]]; then
  keytool -genkeypair -v \
    -keystore "$KEYSTORE" \
    -storepass android \
    -alias androiddebugkey \
    -keypass android \
    -dname "CN=Android Debug,O=Android,C=US" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000
fi

mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/Smriti-${VERSION}-debug.apk"

"$APKSIGNER" sign \
  --ks "$KEYSTORE" \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "$OUT" \
  "$UNSIGNED"

"$APKSIGNER" verify --verbose "$OUT" | head -n 8

echo
echo "APK: $OUT"
echo "Install with: adb install -r \"$OUT\""
