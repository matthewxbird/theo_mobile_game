Always write back learnings: when you discover something non-obvious about this project (setup gotchas, build fixes, device quirks, conventions), add it to the Learnings section below before finishing your task.
Never add a co-author (no `Co-Authored-By` trailers) to commits, and always commit in small batches: one focused change per commit.

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
- Phone only shows in `flutter devices` once USB debugging is on, USB mode is File transfer, and the RSA prompt is accepted.
