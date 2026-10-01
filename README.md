# NucleusUI

The Nucleus design language for native iOS apps, ported from the web apps' CSS
(`core/BackgroundBlobs.vue`, `lg-glass`, `set-*` settings rows, `SegmentPill`,
`BottomSearch`, `WelcomeModal`, `motion.css`). Use it so a standalone Swift app
looks like it belongs to the Nucleus family without depending on Nucleus core.

Shell (`apps/shell`) is the reference app built on it.

## What's inside

| Piece | Web origin | Use |
| --- | --- | --- |
| `Nucleus` tokens, `NucleusTint` | Tailwind palette used across apps | `Nucleus.accent`, `.secondaryText`, `.well`, tile gradients |
| `NucleusBackground` | `BackgroundBlobs.vue` | Put it at the back of every screen |
| `.nucleusGlass(...)`, `GlassCircleButton` | `.lg-glass`, header circle buttons | Native Liquid Glass with the Nucleus violet cast |
| `NucleusPage` | `layouts/PageShell.vue` | Pushed pages: back button + 34 pt title |
| `NucleusSheetPage` | `TemplateModal` / form sheets | Modal forms with cancel/confirm |
| `NucleusSection`, `NucleusRow`, `IconTile`, `NucleusField`, `Chevron` | `SettingsView` `set-*` classes | Grouped glass lists with auto separators |
| `NucleusSegmented` | `WatchlistNav` + `SegmentPill` | Sliding-pill tabs |
| `NucleusSearchBar` | `BottomSearch.vue` | Floating search pill + round add button |
| `NucleusWelcome`, `WelcomePoint` | `WelcomeModal.vue` | First-launch sheet with a spinning glow hero |
| `NucleusEmptyState`, `TintPicker`, `SymbolPicker` | — | Common building blocks |
| `NucleusMotion`, `.nucleusAppear(i)`, `NucleusPressStyle`, `Haptics` | `motion.css` (`nuc-in`, `nuc-stagger`, `nuc-press`) | Consistent easing and staggered entrances |
| `AppearanceMode` | `useTheme.js` | System / Light / Dark, defaulting to dark like the web apps |

## Starting a new Nucleus iOS app

1. Copy `project.yml` from Shell, rename the target and bundle id (`com.nucleushome.<app>`).
2. Add the package: `NucleusUI: { path: ../shell/Packages/NucleusUI }` (or move this
   folder into its own repo and reference it by URL — it has no dependencies).
3. Use the same launch color (`#08060F` dark / `#F4F3FA` light) so nothing flashes on start.
4. Default to dark (`AppearanceMode.dark`) and tint the app with `Nucleus.accent`.
5. Build screens from `NucleusPage` / `NucleusSheetPage` / `NucleusSection` rather than
   `List` and `Form`, so rows get the glass groups and spacing of the web settings pages.

Requires iOS 26 (Liquid Glass).
