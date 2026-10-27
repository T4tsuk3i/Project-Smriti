# Smriti core (Rust)

The Rust crate is the future home of the local memory engine: decay,
reinforcement, overlap scoring, retrieval, and the on-device model boundary.

It is intentionally small right now. The Flutter app works without it; the
bridge will be wired once the Android NDK build is set up.

## Test

```sh
cd rust
cargo test
```

## Build for Android (later)

Requirements: Android NDK, `cargo-ndk`, and the Rust Android targets.

```sh
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
cargo install cargo-ndk
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o ../android/app/src/main/jniLibs build --release
```

The Flutter side will load `libsmriti_core.so` through `dart:ffi`. Do not add
model weights or API keys to this crate.
