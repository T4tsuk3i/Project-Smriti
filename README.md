<div align="center">

# स्मृति · Smriti

### A local-first journal that remembers.

**Android-first. Tauri 2 + Svelte + Rust. No Android Studio. No cloud.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-design%20prototype-orange)
![Tauri](https://img.shields.io/badge/Tauri-2-24c8db)
![Svelte](https://img.shields.io/badge/Svelte-5-ff3e00)
![Rust](https://img.shields.io/badge/Rust-core-b7410e)

</div>

---

Smriti is a quiet journal for people whose brains run on their own schedule. Write a line, pick a mood, set one small intention, and close it. No streaks, no audience, no feed.

It is Android-first. It is built with **Tauri 2, Svelte 5, and Rust**. It does not need Android Studio, and it does not call a cloud model.

Built solo by someone with ADHD. Not medical care. Just the thing that helped me.

> **Status: design prototype.** The UI and local data layer are working. The Rust/SQLite core and on-device model are next.

---

## What works now

- Onboarding: privacy, “not a crisis service,” optional name
- Today: greeting, mood picker, one-thing intention, writing card
- Journal: weekly numbers, seven-day dots, search, edit, delete
- Weekly: entries/words/days, words-per-day chart, local summary
- Stuck sheet: too big / unclear / boring / tired / afraid → one smaller step
- Focus timer: 10 or 25 minutes, no score
- Settings: support country, reminder preference, export, delete everything
- Local safety notice with country helplines
- Model file picker + GGUF registry (inference runtime next)
- Sample week for testing the design

Data is currently stored in `localStorage` so the design can be tested in a browser. SQLite comes next.

A local GGUF file can already be selected and registered. The inference runtime is the next milestone.

## Not built yet

- No model is bundled. A GGUF file can be registered, but inference and reflection are not wired yet.
- No SQLite/Rust persistence yet
- No scheduled notifications yet
- No app lock or encryption yet
- No home-screen widget yet
- No iOS build yet (needs macOS + Xcode)

---

## Design

The design references were warm journal apps with white cards, colour-coded moods, big numbers, and a floating nav. The ADHD rules behind the layout:

1. One primary action per screen
2. Two taps to capture
3. No streaks, no shame
4. Forgiving re-entry
5. Start ridiculously small
6. No infinite feed
7. Visible choices, large touch targets
8. Colour is never the only signal
9. Offline always
10. Quiet by default

Palette: cream paper, white cards, burnt orange, sage, butter, lilac. Bold sans for UI, serif for journal text.

---

## Stack

| Layer | Choice |
|---|---|
| Shell | Tauri 2 |
| UI | Svelte 5 + SvelteKit, static adapter |
| Core | Rust (`rust/` + `src-tauri/`) |
| Data (now) | `localStorage` prototype |
| Data (next) | SQLite in Rust |
| AI (next) | Local GGUF registry; llama.cpp runtime next, no cloud |
| Build | `cargo`/`npm tauri` + Gradle CLI |
| Android Studio | Not required |

---

## Build and run

Requirements:

- Node 20+
- Rust 1.90+ with Android targets
- JDK 21
- Android SDK + NDK
- A physical Android phone with USB debugging (no emulator needed)

```sh
export JAVA_HOME="$HOME/development/jdk-21"
export ANDROID_HOME="$HOME/Android/Sdk"
export NDK_HOME="$HOME/Android/Sdk/ndk/28.2.13676358"
export PATH="$HOME/.cargo/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

npm install
```

Browser preview:

```sh
npm run dev
```

Open `http://localhost:1420`.

Android, on a connected phone:

```sh
npm run tauri android dev
```

Build a signed, installable APK:

```sh
npm run android:apk
```

It lands at `dist/Smriti-0.1.0-debug.apk`.

No Android Studio is required. The Android project is generated at `src-tauri/gen/android`.

Rust tests:

```sh
cd rust
cargo test
```

For the first test pass, see [TESTING.md](TESTING.md).

---

## Privacy

- No account
- No Smriti server
- No analytics
- No model bundled or downloaded
- Data stays on the device
- Export and delete are free

The promise is not “we won’t look.” It is “there is nowhere for us to look.”

---

## Safety

Smriti is **not** a crisis service and **not** medical care. If you are in immediate danger, contact your local emergency number.

The app shows local resources when it detects language that may need care. It cannot monitor you centrally, because there is no server and no plaintext access.

---

## Roadmap

- **v0.2 — Real storage.** SQLite in Rust, migrations, encrypted database.
- **v0.3 — Fits the day.** Notifications, app lock, home-screen widget, share target.
- **v0.4 — On-device model.** Wire the registered GGUF to llama.cpp, memory extraction, weekly letter, ask.
- **v0.5 — Trust.** Safety classifier, trusted contact, export/import.
- **v1.0 — iOS.** Tauri iOS build, requires macOS + Xcode.

---

## Repository layout

```text
.
├── src/                  # Svelte UI
│   └── lib/
│       ├── components/
│       ├── state.svelte.ts
│       ├── weekly.ts
│       └── safety.ts
├── src-tauri/            # Tauri shell + Rust commands
│   └── gen/android/      # generated Android project (no Studio needed)
├── rust/                 # smriti-core: decay, overlap, future memory
├── TESTING.md
└── LICENSE
```

---

## License

MIT. See [LICENSE](LICENSE).

---

## Credits

Built solo by [T4tsuk3i](https://github.com/T4tsuk3i). AI tools were used to assist with development.

---

<div align="center">

**If you have ever wanted a journal that remembers without selling you out, star the repo.**

</div>
