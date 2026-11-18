# mac-app-kit – notes for Claude Code

Shared scripts of the author's Mac apps and a template for new ones; see README.md for how it works.

- `files/` is copied 1:1 into every app by `./sync.sh` (apps in `apps.txt`). After changing anything there, run
  `./sync.sh`, then build and test each app (`./scripts/build-app.sh`, `./scripts/release.sh <current version>`
  without `--publish`) and commit the copies in each app repository. `./sync.sh --check` must report a match.
- Development builds (`DEV_CHANNEL=1`) are `build/<App> Dev.app` with `<id>.dev` (`DEV_APP_BUNDLE` in
  `app-config.sh`); only `release.sh` and `install-local.sh` build `<App>.app` with the real ID, in their own staging
  folders, and remove it afterwards. Never put a dev build at `build/<App>.app` – Spotlight would open it.
- App-specific values belong in the app's `app.conf` (defaults in `files/scripts/app-config.sh`), never in `files/`.
  Keep the scripts working for every app in `apps.txt` (spaces in app names: "Brew GUI").
- `template/` + `new-app.sh` create new apps; test changes with `./new-app.sh "Test App" --dir <temp folder>`
  followed by `./scripts/build-app.sh` and `./scripts/release.sh 0.1.0` there.
- Never run `release.sh --publish`, push, tag or touch the Homebrew tap unless the user explicitly asked.
- Every file starts with the SPDX GPL-3.0-or-later line and `Copyright (C) 2026 Furcenzo`; texts, comments and
  commit messages are in English. Commits are authored by `Furcenzo <60021487+Furcenzo@users.noreply.github.com>`.
- No real names, private e-mail addresses, home directory paths or internal hosts/IPs anywhere (the repository is
  meant to be public).
