# Testing Smriti

This is the v0.1 build: a local journal with moods, a week view, and no model yet. The AI parts are intentionally off.

## Run it from Android Studio

1. Open the `Project-Smriti` folder in Android Studio.
2. Open **Device Manager** and start the emulator. Wait until the Android home screen is visible.
3. In the device dropdown at the top, select the Android emulator, not “Linux desktop”.
4. Open `lib/main.dart`.
5. Click the green **Run** button, or choose **Run 'main.dart'**.

The first Gradle run can take a minute. Lines like these are warnings, not failures:

```text
WARNING: A restricted method in java.lang.System has been called
```

Wait for the app to open. If Android Studio shows a red error, copy the lines after the Gradle warnings.

## Run it from a terminal

Use this only if the Android Studio emulator is already running.

```sh
export PATH="$HOME/development/flutter/bin:$HOME/Android/Sdk/platform-tools:$PATH"
cd /home/tatsuya/Documents/Projects-2/Project-Smriti
flutter devices
flutter run -d emulator-5554
```

## Install the built APK

```sh
export PATH="$HOME/Android/Sdk/platform-tools:$PATH"
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Or copy the APK to your phone and open it.

## Test pass

### 1. Today

- Pick a mood. The chip should tint and the label should change colour.
- Write two or three lines.
- Tap **Save**.
- The entry should appear under **Lately** with the mood chip.
- Tap **See all** to open the Journal.

### 2. Journal

- Check the **This week** card: entries, words, and days.
- Check the seven circles. Days you wrote should have a tick.
- Open an entry and delete it. Confirm the dialog.
- The stats and list should update.

### 3. Weekly

- Tap **Write it up**.
- A plain summary should appear with counts, repeated words, and the longest entry.
- You should see the “Reflection is off” note.
- This page does not call a model.

### 4. Settings

- Change the support country. It should persist after leaving the page.
- Tap **Copy export**, then paste somewhere to check the JSON.
- Tap **Delete everything**. Confirm. The journal should be empty, settings should remain.

### 5. Persistence

- Close the app and reopen it.
- Entries, moods, summaries, and settings should still be there.

### 6. Edge cases

- Empty save should stay disabled.
- Very long text should stay inside the 12,000 character limit.
- Switching tabs and coming back should reload the list.

## Hot reload

With the app running from Android Studio, save a Dart file and use the **Hot Reload** lightning icon, or press `r` in the run console.

## What is not built yet

- No model is bundled or configured. AI reflection, memory extraction, and ask-your-journal are off.
- No account, cloud sync, analytics, or network calls.
- Safety resources are local keyword checks only. Do not use real crisis text to test.
- iOS has a generated host but needs macOS/Xcode to run.

## Current limitations

- Data is in a local SQLite file, not encrypted yet.
- The app is Android-first; the Rust core is not wired through FFI yet.
- A home-screen / linking widget is on the roadmap, not in this build.
