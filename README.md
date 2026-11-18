# mac-app-kit

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Shared build, release and localization scripts of the author's macOS apps ([Lineup](https://github.com/Furcenzo/lineup),
[Brew GUI](https://github.com/Furcenzo/brew-gui)), plus a template for new apps. The apps are Swift Package Manager
projects (SwiftUI/AppKit, no Xcode project), bilingual (English + Slovak), ad-hoc signed and distributed as zip files
on GitHub Releases and through a Homebrew tap.

The scripts are **copied** into each app (`sync.sh`), so every app repository stays self-contained and builds
without the kit. What differs between the apps lives in the app's own `app.conf`.

## What is in it

| Path | What it is |
| --- | --- |
| `files/` | Copied 1:1 into every app (same paths): `scripts/*.sh`, `scripts/app-config.sh`, `scripts/hooks/`, `.githooks/pre-commit`, `.claude/settings.json` |
| `template/` | Skeleton of a new app (`new-app.sh` fills in the names) |
| `sync.sh` | Copies `files/` into the apps or checks that they still match |
| `new-app.sh` | Creates a new app from `template/` |
| `apps.txt` | The apps `sync.sh` works on without arguments (folders relative to the kit) |

The scripts in an app (all run from anywhere, they `cd` to the repository root):

| Script | Does |
| --- | --- |
| `scripts/build-app.sh` | `swift build -c release` + `.app` bundle in `build/`: Info.plist, icon, `*.lproj`, signature. Development builds are "<App> Dev" with bundle ID `<id>.dev` (`DEV_CHANNEL=1`) and are signed with the local "<App> Local Dev" certificate, so macOS keeps their permissions between builds |
| `scripts/run.sh [sk\|en]` | Build, quit the running app, start the new build (optionally in another language) |
| `scripts/release.sh <version> [--publish]` | Tests, localization check, universal ad-hoc signed build, zip in `build/`. `--publish` also tags, creates the GitHub Release (notes from `CHANGELOG.md` + `scripts/release-notes.md`), bumps the cask in the Homebrew tap and refreshes the showroom website |
| `scripts/check-localization.sh` | Every localizable text in the code has a translation in every `<lang>.lproj`, matching format specifiers, no Slovak in code |
| `scripts/make-icon.sh` | Runs the app's own `scripts/icon/AppIcon.swift` (1024 px PNG) and builds the `.icns` |
| `scripts/setup-dev-signing.sh` | One-time: creates the self-signed "<App> Local Dev" code signing certificate (asks for the login password) |
| `scripts/install-local.sh [version]` | The author's Mac: installs a dev-signed build of the latest tag into /Applications |
| `scripts/hooks/claude-stop-l10n.sh` | Claude Code `Stop` hook: refuses to finish while translations are missing |
| `.githooks/pre-commit` | Same check before a commit (`git config core.hooksPath .githooks`) |

## app.conf

A zsh file in the root of each app. Required: `APP_NAME`, `EXECUTABLE`, `BUNDLE_ID`, `GITHUB_REPO`. Everything else
has a default in [`files/scripts/app-config.sh`](files/scripts/app-config.sh):

```sh
APP_NAME="Lineup"                         # name of the .app
EXECUTABLE="Lineup"                       # Swift executable target (Sources/<EXECUTABLE>)
BUNDLE_ID="io.github.furcenzo.lineup"
GITHUB_REPO="Furcenzo/lineup"
CASK="lineup"                             # Casks/<CASK>.rb in TAP_REPO (Furcenzo/homebrew-tap); empty = no cask
SITE_SLUG="lineup"                        # argument of the showroom site's update-site.sh; empty = skip
CATEGORY="public.app-category.utilities"
MIN_MACOS="15.0"
AGENT_APP=1                               # menu bar only (LSUIElement)
DEV_CHANNEL=1                             # development builds are "Lineup Dev" (<BUNDLE_ID>.dev)
# Optional: RESOURCES (default Sources/<EXECUTABLE>/Resources), ICON_ICNS / ICON_PNG (default Assets/AppIcon.*),
# ICON_SOURCE, ZIP_NAME (default APP_NAME with dashes), DEV_IDENTITY, COPYRIGHT, INFO_PLIST_EXTRA, RELEASE_NOTES
```

App-specific files that the kit never overwrites: `app.conf`, `scripts/release-notes.md` (the Download part of the
GitHub Release; placeholders `@CHANGES@`, `@ZIP@`, `@ZIP_URL@`, `@VERSION@`, `@SHA@`), `scripts/icon/AppIcon.swift`
and any other scripts of the app (e.g. Brew GUI's `scripts/screenshots.sh`).

## Changing a shared script

1. Edit it in `files/` (never in an app – `sync.sh` would overwrite it).
2. `./sync.sh` copies it into every app in `apps.txt` (or `./sync.sh ../Lineup` into one).
3. In each app: build / test, then commit the copied files.

`./sync.sh --check` lists the files that differ from the kit (exit code 1 if any), `./sync.sh --diff` shows the
differences.

## Creating a new app

```sh
./new-app.sh "Connection Manager"      # → ../Connection Manager, added to apps.txt
cd "../Connection Manager" && ./scripts/run.sh
```

Options: `--dir <folder>`, `--bundle-id <id>` (default `io.github.furcenzo.<name>`), `--slug <slug>` (GitHub repository
and cask name, default `connection-manager`). The new app has a core library + SwiftUI app + tests, English and Slovak
texts, a placeholder icon (first letter of the name), `app.conf`, README, CHANGELOG, CLAUDE.md, LICENSE
(GPL-3.0-or-later) and a git repository with one commit authored by Furcenzo. Nothing is pushed: create the GitHub
repository and the Homebrew cask when the app is ready for its first release.

## License

GPL-3.0-or-later – see [LICENSE](LICENSE). Copyright (C) 2026 Furcenzo. `setup-dev-signing.sh` is based on AltTab's
`scripts/codesign` ([lwouis/alt-tab-macos](https://github.com/lwouis/alt-tab-macos), GPL-3.0).
