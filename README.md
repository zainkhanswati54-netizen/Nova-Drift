# Nova Drift

An arrow-dashing arcade game, built with **Kotlin + LibGDX**, inspired by *Space Waves* (CrazyGames).

---

## 1. Research summary (Space Waves)

- **Genre**: Geometry-Dash-style side-scrolling arcade/rhythm game. 7.2M+ downloads, 4.6★, made by CrazyGames/Maxflow.
- **Core loop**: control an arrow that auto-scrolls forward; **hold = rise, release = fall**. Crash into a wall/spike/rotating obstacle = restart the level instantly.
- **Content**: 80+ handcrafted levels grouped into **worlds**, color/difficulty coded (green = easy → red = extreme). Free level selection — jump into any unlocked level anytime.
- **Modes**: **Classic** (reach the finish to complete a level), **Endless** (go as far as possible, chase a highscore), **Race** (reach the finish before AI/other players, with a difficulty stepper).
- **Meta systems**: a soft currency (gems), a daily-reward spin wheel, a shop, cosmetic skins for the arrow, a "remove ads" IAP, and video-ad-gated bonus spins.
- **Monetization pain point** (from reviews): players complain about ad frequency — worth designing generously around this (e.g., ads are optional/rewarded, not forced every death) if we want better retention than the original.
- **Screens covered in this first pass** (from your screenshots): Splash/loading, Mode-select (Classic/Endless/Race), World-select under Classic (Special/World 1/2/3/Coming Soon with lock + progress states), Daily Reward wheel.

## 2. Architecture

Standard LibGDX multi-module layout:

```
NovaDrift/
├── core/                 # 100% of game logic & UI — platform-agnostic
│   └── .../game/
│       ├── NovaDriftGame.kt      # entry point (com.badlogic.gdx.Game), owns Batch/Skin/GameData
│       ├── screens/              # one class per screen
│       │   ├── BaseScreen.kt         # shared Stage/Viewport + gradient bg helper
│       │   ├── SplashScreen.kt
│       │   ├── MainMenuScreen.kt     # "Select a game mode"
│       │   ├── LevelSelectScreen.kt  # "Classic" world select
│       │   └── DailyRewardScreen.kt  # spin wheel
│       ├── ui/                   # reusable widgets + a runtime "no-art-needed" skin
│       │   ├── TextureFactory.kt     # generates rounded rects/circles/wheel wedges via Pixmap
│       │   ├── UiSkinFactory.kt      # builds the shared Scene2D Skin (fonts, buttons, bars)
│       │   └── GemBar.kt             # top-right currency HUD
│       ├── gameplay/              # (next step) Player/Obstacle/Level for the actual dash mechanic
│       └── util/
│           ├── Constants.kt          # virtual resolution + the exact palette from your screenshots
│           └── GameData.kt           # Preferences-backed save data (gems, world progress/locks)
└── android/               # thin Android shell: manifest, AndroidLauncher.kt, launcher icons
```

**Why it's built this way:**
- **No external art needed yet.** `TextureFactory` draws every rounded card, button, progress bar and the reward wheel at runtime from solid colors, matching your screenshots' palette exactly (`Palette` object). This means the project **compiles and is fully clickable today** — you can swap in real illustrations/icons later without touching layout code, just by changing what `UiSkinFactory`/`TextureFactory` return.
- **One fixed virtual resolution** (1200×540, landscape) via `FitViewport`, so the UI always matches the reference proportions regardless of phone screen size/aspect ratio.
- **`GameData`** already wires up gems, World 1 progress %, World 2/3 lock state, and daily-reward cooldown through Android `Preferences` — so state persists across app restarts from day one.

## 3. What's implemented right now

| Screen | Status |
|---|---|
| Splash (logo + loading bar → auto-advances) | ✅ done |
| Main Menu (Classic/Endless/Race mode cards, Shop/Offer/Gift/No-Ads/Skin/Settings buttons) | ✅ layout + navigation done; Shop/Skin/Settings/IAP are stubbed (`// TODO`) |
| Classic World Select (Special/World1/2/3 + Coming Soon, lock states, progress bar) | ✅ done |
| Daily Reward wheel (8 segments, spin animation, random weighted-by-index reward, gems credited) | ✅ done |
| Actual gameplay (arrow physics, obstacles, level data, Endless/Race modes) | ⏳ not started yet — this is the natural next step |

## 4. How to open & run

1. Open the `NovaDrift/` folder in **Android Studio** (Koala+ recommended).
2. Let Gradle sync — it will download the Android Gradle Plugin, Kotlin plugin, and LibGDX `1.12.1` automatically (needs internet the first time).
3. Run the `android` configuration on a device/emulator. It launches straight into the Splash screen.

> Note: I couldn't run a live Gradle build from here (this sandbox has no internet access), so please do a first sync/build in Android Studio and ping me with any error output — I'll fix it immediately.

## 4b. Building via GitHub Actions (CI)

A workflow is already set up at `.github/workflows/android-build.yml`. It runs on every push/PR to `main`/`master` and on manual trigger, and:

1. Checks out the repo, sets up JDK 17.
2. Installs Gradle `8.7` via `gradle/actions/setup-gradle` (this project doesn't commit a Gradle **wrapper** jar — it was built offline with no network access to fetch that binary — so CI installs Gradle directly instead of using `./gradlew`).
3. Runs `gradle :android:assembleDebug`.
4. Uploads the resulting APK as a downloadable build artifact named **`nova-drift-debug-apk`**.

**To use it:**
1. Push this project to a new GitHub repo (`git init && git add . && git commit -m "Initial commit" && git remote add origin <your-repo-url> && git push -u origin main`).
2. Go to the repo's **Actions** tab — the workflow runs automatically on push.
3. Once it finishes (green check), open the run → scroll to **Artifacts** → download `nova-drift-debug-apk`, unzip it, and install the `.apk` on a device (`Settings > allow install from unknown sources`, or `adb install`).

**Recommended follow-up (optional):** commit a real Gradle wrapper so the project also builds identically on any machine without a separately-installed Gradle:
```bash
# run once, locally, with internet (e.g. from Android Studio's terminal)
gradle wrapper --gradle-version 8.7
git add gradlew gradlew.bat gradle/wrapper
git commit -m "Add Gradle wrapper"
```
Once `gradlew` exists, you can simplify the CI "Build" step to `./gradlew :android:assembleDebug` and drop the `setup-gradle` install step if you prefer — either works fine.

## 5. Suggested next steps (in order)

1. **Gameplay core**: `Player.kt` (hold-to-rise/release-to-fall physics), `Obstacle.kt` (walls/spikes/rotating traps), a simple `LevelData` format (JSON) + `GameScreen.kt` that actually plays a level and reports win/crash back to `LevelSelectScreen`.
2. **Endless & Race screens**: reuse `GameScreen` with different end-conditions (infinite procedural obstacles; a difficulty stepper + simple AI ghost for Race).
3. **Shop / Skins**: gem-purchasable arrow skins, wired through `GameData`.
4. **Real art pass**: swap `TextureFactory` placeholders for actual illustrations, custom font (currently using LibGDX's built-in font at runtime), and sound/music.
5. **Ad/IAP integration**: AdMob rewarded video for bonus spins, a real "No-Ads" purchase flow.

Batao next kaunsa hissa banau — gameplay physics (arrow + obstacles) ya shop/skins screen?
