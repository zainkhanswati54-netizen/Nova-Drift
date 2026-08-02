# Nova Drift (Flutter + Flame)

Arcade wave-rider game UI inspired by the reference design.
Built with **Flutter** (menus) + **Flame** (gameplay engine, coming soon).

## Current status

| Feature | Status |
| --- | --- |
| Game mode select (CLASSIC / ENDLESS / RACE) | Done - colour-cycling background + starfield |
| Level select (SPECIAL / WORLD 1-3) | Done - World 1 open, rest locked |
| Gems counter + persistence | Done (shared_preferences) |
| Settings (sound toggle, language, restore purchases, privacy/terms) | Done - animated screen, orange theme |
| Shop / Offer / Gift / No-Ads / Skin | Coming Soon dialogs |
| App icon (launcher + adaptive) | Done - generated via `flutter_launcher_icons` in CI |
| Gameplay (Flame) | Done - Classic (fixed level), Endless (procedural, ramping speed, saved best distance), Race (AI rival, win/lose) all now behave differently. Gem pickups scattered on every mode. |
| Visible error screen instead of a silent blank/blue screen on a widget crash | Done |

## How to run (Android)

This project is code-only here - run it locally:

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (3.27+ required)
2. Download this project (ZIP or git clone)
3. In the project folder, generate the platform folders once:

   ```bash
   flutter create . --platforms=android
   flutter pub get
   flutter run
   ```

   The app is landscape-only and fullscreen, like the reference game.

## Build APK with GitHub Actions (no local setup needed)

This repo ships with `.github/workflows/build-apk.yml`. Once the project is
pushed to GitHub:

1. Every push to `main`/`master` automatically builds the APK
   (you can also trigger it manually from the **Actions** tab → *Build Android APK* → **Run workflow**)
2. When the run finishes, open the run page and download the APK from **Artifacts** →
   `nova-drift-apk` — a single universal APK that installs on any device.
3. Optional: push a git tag like `v1.0.0` and the workflow attaches the APK to a GitHub Release automatically.

> Previously this workflow also built `--split-per-abi` APKs, which is why you'd see
> 4 files in the Artifacts (1 universal + 3 per-architecture). That step has been
> removed — one push now produces exactly one APK.

The workflow runs `flutter create . --platforms=android` itself, so the
`android/` folder does not need to be committed. The APK is signed with the
debug key by default — fine for testing/sideloading. For Play Store uploads
you will need a proper signing key later.

## Project structure

```
lib/
  main.dart                     # App entry, landscape lock, fullscreen
  core/
    app_theme.dart              # Colour palettes (blue/red/green/orange) + lerp cycling
    app_text.dart               # Bold rounded game typography (Google Fonts Rubik)
    game_state.dart             # Gems + progress, persisted with shared_preferences
  widgets/
    starfield_background.dart   # Twinkling star dots over the background
    game_button.dart            # Bordered filled/outline buttons
    gem_counter.dart            # Top-right gem pill + "+" button
    mode_card.dart              # CLASSIC / ENDLESS / RACE card
    coming_soon_dialog.dart     # Styled "COMING SOON" dialog
    settings_option_button.dart # Animated bordered row-button (Settings screen)
    mini_switch.dart            # Small animated on/off pill (Sound row)
  screens/
    mode_select_screen.dart     # "SELECT A GAME MODE" main menu
    level_select_screen.dart    # "CLASSIC" world select (green theme)
    settings_screen.dart        # "SETTINGS" screen (orange theme, animated)
    gameplay_screen.dart        # Hosts the Flame GameWidget
  game/
    nova_drift_game.dart        # Flame game skeleton (plug gameplay in here)
assets/
  icon/
    icon.png                    # 1024px launcher icon (legacy/iOS)
    icon_background.png         # Adaptive icon background layer
    icon_foreground.png         # Adaptive icon foreground layer (the mark)
```

## Adding the real gameplay later

Open `lib/game/nova_drift_game.dart` - the `NovaDriftGame` class is a
ready `FlameGame`. Add the arrow-ship player component (tap/hold to fly up),
spike obstacles, and the finish line there; the menus already route every
START button into it with the selected mode string.
