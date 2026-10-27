<div align="center">

# स्मृति · Smriti

### A local-first journal that remembers.

**Android-first. Flutter + Rust. On-device AI. Your words stay on your phone.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-early%20development-orange)
![Flutter](https://img.shields.io/badge/Flutter-mobile-blue)
![Rust core](https://img.shields.io/badge/Rust-core-orange)
![On-device](https://img.shields.io/badge/AI-on--device-brightgreen)

</div>

---

Smriti is a quiet, private journal for people whose brains run on their own schedule. Write a short check-in; the app keeps it on your phone, shows you the thread over time, and — once on-device model support lands — writes you a weekly reflection without sending your life to a server.

Built solo by someone with ADHD. Not medical care. Just the thing that helped me.

> **Status: early development.** This is an Android-first mobile app, not a desktop app. Basic offline journaling is the current milestone. On-device AI is next.

---

## Why mobile only

The phone is where the check-in actually happens. A desktop journal asks you to sit down; a phone journal meets you where you are.

Smriti is:

- **Android first.** Free to build, test, and sideload.
- **iOS later.** Local builds can use free personal provisioning; App Store distribution requires the paid Apple Developer Program.
- **Not a desktop app.** No Tauri, no Electron, no browser tab.
- **On-device by design.** Models are meant to run on the phone. No cloud inference. No model is bundled or configured yet.

---

## The plan

1. **Write.** A short text check-in, saved locally.
2. **Remember.** The Rust core will handle memory decay, reinforcement, and retrieval locally.
3. **Reflect.** Once an on-device model is selected, Smriti writes a weekly letter from your own entries.
4. **Ask.** Later: “When did I last feel excited about work?” answered from local memory, with citations.
5. **Capture fast.** A home-screen / linking widget is on the roadmap for one-tap check-ins.

No streaks. No shame. No engagement traps.

---

## Current state

Working now:

- Local journal entries
- Timeline
- Local weekly summary (no AI required)
- Delete entries
- Settings
- Local safety-resource notice

Intentionally not configured yet:

- **No model.** The model section is blank on purpose. Smriti does not bundle weights, download a model, or call a cloud API.
- Memory extraction, AI letters, and ask-your-journal stay off until a local model is wired.

The app should still be useful without a model. That is the point.

---

## Stack

| Layer | Choice |
|---|---|
| Mobile UI | Flutter (Material 3, dark, calm) |
| Core | Rust (`rust/`) — memory primitives, local scoring, future FFI |
| Local data | SQLite on device |
| AI | On-device GGUF via llama.cpp (roadmap) |
| Cloud | None |
| Desktop | None |

The Rust crate currently contains tested primitives for decay, Jaccard overlap, and keyword overlap. The Flutter app runs independently until the FFI bridge is added.

---

## Roadmap

- **v0.1 — Local journal.** Write, timeline, local weekly summary, settings. *(current)*
- **v0.2 — Rust core + encrypted storage.** Wire the Rust core through FFI; encrypt the local database.
- **v0.3 — On-device model.** Pick a local GGUF; memory extraction; AI weekly letter. Still no cloud.
- **v0.4 — iOS.** Free personal provisioning first; App Store only if the paid program is worth it.
- **v0.5 — Linking widget.** Home-screen widget, share target, or quick-capture tile.
- **v0.6 — Export / import.** Portable encrypted backup.

The roadmap is a direction, not a promise.

---

## Privacy

- No Smriti server.
- No account.
- No telemetry by default.
- Entries live in a local SQLite file on the phone.
- No model is configured or downloaded right now.
- When on-device AI lands, inference runs on the phone.
- No cloud model is planned for the default path.

The promise is not “we won’t look.” It is “there is nowhere for us to look.”

---

## Safety

Smriti is **not** a crisis service and **not** medical care. If you are in immediate danger, contact your local emergency number.

The app can show support resources when it detects language that may need care. It cannot monitor you centrally, because it has no server and no plaintext access. That trade is stated plainly.

---

## Build

Requirements:

- Flutter 3.47+ / Dart 3.13+
- Android SDK (for Android builds)
- Rust 1.90+ (for the core crate)

```sh
flutter pub get
flutter run
```

Build the debug APK:

```sh
flutter build apk --debug
```

It lands at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

For a step-by-step first test, see [TESTING.md](TESTING.md).

Rust tests:

```sh
cd rust
cargo test
```

Android SDK, NDK, and the Rust FFI bridge are not bundled in this repo. The Flutter app does not require the Rust bridge yet.

---

## Repository layout

```text
.
├── android/          # Flutter Android host
├── ios/              # Flutter iOS host (later)
├── lib/              # Flutter app
│   ├── data/         # SQLite + repositories
│   ├── models/
│   ├── screens/
│   ├── services/     # model boundary, safety
│   └── widgets/
├── rust/             # Rust core
│   ├── src/
│   └── Cargo.toml
├── README.md
└── LICENSE
```

---

## Contributing

Feedback, safety review, and bug reports are welcome. Open an issue or start a discussion.

If you work in mental health, safety, or privacy, your review matters more than a pull request.

---

## License

MIT. See [LICENSE](LICENSE).

---

## Credits

Built solo by [T4tsuk3i](https://github.com/T4tsuk3i). AI tools were used to assist with development.

---

<div align="center">

**If you have ever wanted a journal that remembers without selling you out, star the repo.**

That is the signal that this should exist.

</div>
