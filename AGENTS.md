These three rules MUST always be followed:

1. **Never attribute to AI.** No `Co-Authored-By` trailers, "Generated with" lines, or any AI/agent mention in commits, PRs, code comments or docs.
2. **Always write back learnings.** When you discover something non-obvious about this project (setup gotchas, build fixes, device quirks, conventions), add it to the Learnings section below before finishing your task.
3. **Always commit and push as you go.** Commit each change as soon as it is done, in small batches (one focused change per commit), and push to `origin` straight after. Don't batch everything up for the end of a task.

# AGENTS.md

## Project

- Flutter mobile game app (`theo_mobile_game`), targets Android and iOS.
- Entry point: `lib/main.dart`. Tests: `test/`.

## Commands

- Install deps: `flutter pub get`
- Analyze: `flutter analyze`
- Test: `flutter test`
- Run on device: `flutter devices` then `flutter run -d <device-id>`

## Learnings

- Dev machine is Windows. `adb` is not on PATH; use `%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe`.
- Android Studio's bundled JDK is Java 25. Flutter 3.29 could not build with it (Gradle 8.x won't run on Java 25; Flutter 3.29's Gradle plugin breaks on Gradle 9). Fixed by upgrading Flutter to 3.50.1 (Gradle 9.5, AGP 9.3). Don't hand-bump Gradle on old Flutter.
- Android build needs NDK 28.2.13676358; auto-install fails until SDK licenses accepted (`flutter doctor --android-licenses`), and may still fail after. Install manually with `sdkmanager.bat --package_file=<file>` where the file contains `ndk;28.2.13676358`: passing `ndk;...` as an argument breaks because the `.bat` (cmd) splits on `;`. Set `JAVA_HOME` to Android Studio's `jbr` first.
- Test device: Samsung Galaxy S24 FE (SM-S721B, adb id `R5CX92M56ZT`). Run with `flutter run -d R5CX92M56ZT`. Its logcat is very noisy (`I/GSC` lines).
- Phone only shows in `flutter devices` once USB debugging is on, USB mode is File transfer, and the RSA prompt is accepted.
