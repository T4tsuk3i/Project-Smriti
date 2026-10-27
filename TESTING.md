# Testing Smriti

This is the Tauri + Svelte + Rust prototype. No Android Studio. No emulator required.

## 1. Browser preview

```sh
npm install
npm run dev
```

Open `http://localhost:1420`.

This is the fastest way to test the design, copy, keyboard behaviour, and layout. Data is stored in `localStorage`.

## 2. Desktop shell

```sh
npm run tauri dev
```

The window is sized like a phone (420 × 900). This checks that the app works inside the Tauri webview.

## 3. Android phone

You need a USB data cable and USB debugging enabled on the phone.

```sh
export JAVA_HOME="$HOME/development/jdk-21"
export ANDROID_HOME="$HOME/Android/Sdk"
export NDK_HOME="$HOME/Android/Sdk/ndk/28.2.13676358"
export PATH="$HOME/.cargo/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

adb devices
npm run tauri android dev
```

If `adb devices` is empty, check the cable and the USB mode. Use **File transfer / MTP**, not charge-only.

No Android Studio is needed. Tauri uses Gradle CLI under the hood.

## 4. Build an APK

```sh
npm run android:apk
```

It builds and signs a debug APK at:

```text
dist/Smriti-0.1.0-debug.apk
```

Install it with:

```sh
adb install -r dist/Smriti-0.1.0-debug.apk
```

## Test pass

### Onboarding

- Open the app for the first time.
- Enter a name or skip.
- Tap **Start**.
- Close and reopen — onboarding should not appear again.

### Today

- Pick a mood. It should tint.
- Type two or three lines in the single writing box.
- Tap **Save**.
- The entry should appear under **Lately**.
- Optional: tap **One thing** or **Tiny win** to reveal an input. Tap **Stuck** for the smaller-step sheet.

### Journal

- Check **This week**: entries, words, days.
- Check the seven-day date strip. Today should be highlighted with its mood emoji.
- Search for a word from your entry.
- Edit an entry; change the mood and text; save.
- Delete an entry; confirm.
- If empty, tap **See a sample week**.

### Weekly

- Check the stats and the words-per-day chart.
- Tap **Write it up**.
- A summary should appear with counts, repeated words, and the longest entry.
- It should end with “No model read this.”

### Stuck sheet

- Tap **Stuck? Start smaller**.
- Pick **Too big**, **Unclear**, **Boring**, **Tired**, or **Afraid**.
- A small next step should appear.
- No diagnosis, no lecture.

### Focus timer

- Open the timer icon in the header.
- Choose 10 or 25 minutes.
- Start, pause, reset.
- Let it finish or stop it. No score is saved.

### Model

- In the Android app, open **Settings → Model → Choose model file**.
- Pick a local `.gguf` file.
- The card should show the file name and size.
- Pick **Remove** and confirm it returns to “Not set up”.
- In the browser preview this button is disabled; browser preview cannot read local model files.

### Settings

- Change the support country.
- Change the reminder time. On Android it should request notification permission and schedule a daily notification plus a Sunday 10:00 nudge.
- Use **Turn off** to cancel the reminders.
- Tap **Copy export**, paste somewhere, check the JSON.
- Tap **Delete everything**, confirm. The journal should empty; settings remain.
- Check the Rust core version in About. It says “web preview” in the browser; inside Tauri it shows the core version.

### Persistence

- Close and reopen the app.
- Entries, moods, one-thing, summaries, name, and settings should remain.

## What is not built yet

- No model is included. A GGUF file can be registered, but inference and reflection are not wired yet.
- Data is in `localStorage`, not encrypted SQLite yet.
- Notifications are not scheduled yet.
- No app lock, widget, or iOS build yet.
- Safety resources are local keyword checks. Do not use real crisis text to test.

## Reset

In the browser, clear site data for `localhost:1420`.

On Android, clear the app’s storage from Android settings, or use **Delete everything** in the app.
