# NucleusUI

The Nucleus design language for native apps. One repo for every platform:

| Folder | What's in it |
| --- | --- |
| `tokens/tokens.json` | Colors, tints, radii and motion, the single source for all platforms |
| `scripts/generate_tokens.py` | Writes each platform's code from the tokens |
| `swift/` | The SwiftUI package (`Package.swift` at the repo root points here) |
| `android/` | The Jetpack Compose library, not started yet |

## Changing a color, radius or timing

Edit `tokens/tokens.json`, run `python3 scripts/generate_tokens.py`, and commit both the JSON and the
generated files. Never edit `swift/Sources/NucleusUI/Tokens.swift` by hand.

## SwiftUI

The Nucleus design language for native iOS apps, ported from the web apps' CSS
(`core/BackgroundBlobs.vue`, `lg-glass`, `set-*` settings rows, `SegmentPill`,
`BottomSearch`, `WelcomeModal`, `motion.css`). Use it so a standalone Swift app
looks like it belongs to the Nucleus family without depending on Nucleus core.

Shell (`apps/shell`) and Watchlist (`apps/watchlist/ios`) are built on it.

### What's inside

| Piece | Web origin | Use |
| --- | --- | --- |
| `Nucleus`, `NucleusTint`, `NucleusRadius`, `NucleusMotion` | `tokens/tokens.json` | `Nucleus.accent`, `.secondaryText`, `.well`, tile gradients, radii, easing |
| `NucleusBackground` | `BackgroundBlobs.vue` | Put it at the back of every screen |
| `.nucleusGlass(...)`, `GlassCircleButton`, `NucleusGlassContainer` | `.lg-glass`, header circle buttons | Native Liquid Glass with the Nucleus violet cast |
| `NucleusPage` | `layouts/PageShell.vue` | Pushed pages: back button + 34 pt title |
| `NucleusSheetPage` | `TemplateModal` / form sheets | Modal forms with cancel/confirm |
| `NucleusSection`, `NucleusRow`, `IconTile`, `NucleusField`, `Chevron` | `SettingsView` `set-*` classes | Grouped glass lists with auto separators |
| `NucleusSegmented` | `WatchlistNav` + `SegmentPill` | Sliding-pill tabs |
| `NucleusSearchBar` | `BottomSearch.vue` | Floating search pill + round add button |
| `NucleusWelcome`, `WelcomePoint` | `WelcomeModal.vue` | First-launch sheet with a spinning glow hero |
| `NucleusEmptyState`, `TintPicker`, `SymbolPicker` | — | Common building blocks |
| `.onHorizontalSwipe(_:perform:)` | `useSwipeTabs.js` | Swipe between tabs, also over scroll views |
| `.nucleusAppear(i)`, `NucleusPressStyle`, `Haptics` | `motion.css` (`nuc-in`, `nuc-stagger`, `nuc-press`) | Consistent easing and staggered entrances |
| `AppearanceMode` | `useTheme.js` | System / Light / Dark, defaulting to dark like the web apps |
| `NucleusTheme`, `NucleusAccent`, `NucleusAccentPicker`, `.nucleusAccentTint()` | nucleus-web `configurator.js`, `useAppearance.js` | The accent presets (Nucleus, Midnight, Arctic, Ember, Forest) or a custom colour. `NucleusTheme.shared.app` is the app's own (sync it with the app's data); `.account` is the Nucleus ID account's (`appearance` in `/oauth/userinfo`, set with `PUT /oauth/appearance`) and wins while set. `Nucleus.accent`, `primaryGradient`, glass and the background follow it |

### Starting a new Nucleus iOS app

1. Copy `project.yml` from Shell, rename the target and bundle id (`com.nucleushome.<app>`).
2. Add the package by URL: `NucleusUI: { url: https://github.com/NucleusHub/nucleus-native-ui, from: 0.1.0 }`.
3. Use the same launch color (`#08060F` dark / `#F4F3FA` light) so nothing flashes on start.
4. Default to dark (`AppearanceMode.dark`), put `.nucleusAccentTint()` on the root view and offer
   `NucleusAccentPicker()` in Settings.
5. Build screens from `NucleusPage` / `NucleusSheetPage` / `NucleusSection` rather than
   `List` and `Form`, so rows get the glass groups and spacing of the web settings pages.

Requires iOS 17. On iOS 26 glass is native Liquid Glass; on 17–25 it falls back to a
blurred material with the same tint and a hairline edge.
