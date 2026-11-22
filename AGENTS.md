These three rules MUST always be followed:

1. **Never attribute to AI.** No `Co-Authored-By` trailers, "Generated with" lines, or any AI/agent mention in commits, PRs, code comments or docs.
2. **Always write back learnings.** When you discover something non-obvious about this project (setup gotchas, build fixes, device quirks, conventions), add it to the Learnings section below before finishing your task.
3. **Always commit and push as you go.** Commit each change as soon as it is done, in small batches (one focused change per commit), and push to `origin` straight after. Don't batch everything up for the end of a task.

# AGENTS.md

## Project

- "Teddy's Sweet Run": a Flutter + Flame game for a 4-year-old, targets Android and iOS. Requirements: `docs/REQUIREMENTS.md`.
- `lib/main.dart`: app shell; Flutter widgets HUD (`lib/ui/hud.dart`) stacked over the `GameWidget`.
- `lib/game/teddy_game.dart`: game loop, spawning, pickups, catching. Uses simple distance checks, not Flame's collision system.
- Monster speed = level speed × hunger boost ÷ fatness (`GameRules.monsterSpeed`). Fatness and hunger live on each `Monster` and change in its `update`. Stolen lollipops are `StolenLolly` components that call `monster.eat()` when they arrive.
- `lib/game/rules.dart`: every tuning number (speeds, counts, timers). Change difficulty here. Tested in `test/game_rules_test.dart`.
- `lib/game/components/`: Teddy, monsters, sweets, honey. All art is drawn with `Canvas`; there are no image assets yet.
- Sound effects: `lib/game/sfx.dart` (`Sfx.sweet.play()` etc., using `flame_audio` `AudioPool`s preloaded in `onLoad`). The WAVs in `assets/audio/` are generated from sine waves by `tool/generate_sounds.dart` (`dart run tool/generate_sounds.dart`): edit the script and rerun it to change a sound, don't hand-edit the WAVs.
- Screens are driven by `TeddyGame.phase` (`menu` → `ready` → `playing` → `levelComplete`). Game logic only runs while `playing`. `lib/main.dart` switches between Flutter overlays (`lib/ui/start_screen.dart`, `get_ready.dart`, `level_complete.dart`) on top of the `GameWidget`.
- Teddy art is shared: `paintTeddy()` in `lib/game/teddy_colour.dart` is used by both the game component and the menus (`TeddyPicture`).
- Leaderboard: `lib/game/leaderboard.dart`, stored with `shared_preferences` (best level per teddy colour). Check it on the phone with `adb shell run-as com.theo.theo_mobile_game cat shared_prefs/FlutterSharedPreferences.xml`.
- Big celebratory animations (e.g. honey-to-bee, `lib/ui/honey_to_bee.dart`) are Flutter overlays, not Flame components. The game bumps a `ValueNotifier<int>` event counter (`honeyTurnedIntoBee`) and the overlay plays when it changes. Any reward the animation delivers is applied by the game on a timer (`_beesOnTheWay`), so it still lands if the screen changes mid-animation.
- HUD button and badge sizes live in `lib/game/layout.dart` (`HudLayout`). The HUD draws with them, and the game uses them to keep pickups out from under the buttons. Change sizes there, never as literals in the widgets.
- Components are added straight to the game (screen coordinates), not to `world`, so there is no camera to think about.
- Game state the HUD shows (`score`, `honey`) is exposed as `ValueNotifier`s on `TeddyGame`.

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
- `package:flutter/material.dart` is deprecated in Flutter 3.50 (analyzer warns, points to `material_ui`). The app uses only `package:flutter/widgets.dart`; keep it that way unless Material is really needed.
- Screenshots from the phone: use the Bash tool, `adb exec-out screencap -p > shot.png`. PowerShell `>` corrupts the binary PNG. Simulate taps with `adb shell input tap X Y` (physical pixels; the S24 FE screen is 1080x2340).
- To confirm a sound played on the phone without listening: `adb logcat -c`, trigger it, then grep logcat for `Received media started message`.
- `python3` isn't available in Git Bash on this machine; write helper scripts in Dart (`tool/`) instead.
- The phone is often being played by a person while you test. Check with a screenshot before simulating taps, and don't press Home or Play mid-game (it resets their progress).
- The Bash tool blocks `sleep N && ...`. Wait on the `flutter run` terminal output instead, or put the delay inside a script.
- To ship a code change to the phone without wiping someone's game, press `r` (hot reload, keeps state) in the `flutter run` terminal, not `R` or a restart. Agents can't type into a running terminal tab, so ask the user to press it.
- New sound files need a full restart, not hot reload: `Sfx.load()` only runs in `onLoad`. Check they loaded with `adb logcat -d | grep -o "getDuration: [0-9]* (msec)" | sort -u` (one line per sound).
- After adding a package, hot reload isn't enough: stop `flutter run` and start it again.
- Phone only shows in `flutter devices` once USB debugging is on, USB mode is File transfer, and the RSA prompt is accepted.
