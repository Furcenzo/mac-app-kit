#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Furcenzo
#
# Creates a new Mac app from the template: Swift package (core library + SwiftUI app + tests), English and
# Slovak texts, placeholder icon, app.conf, README, CHANGELOG, CLAUDE.md, LICENSE (GPL-3.0-or-later), the shared
# scripts (sync.sh) and a git repository with one commit by Furcenzo.
#   ./new-app.sh "Connection Manager"                      → ../Connection Manager
#   ./new-app.sh "Connection Manager" --dir <folder> --bundle-id <id> --slug <slug>
# Defaults: executable ConnectionManager, bundle ID io.github.furcenzo.connectionmanager,
# slug (GitHub repository Furcenzo/<slug>, Homebrew cask) connection-manager.
# Nothing is pushed or published: create the GitHub repository and the cask yourself when the app is ready.
set -euo pipefail
KIT="${0:A:h}"

usage() { sed -n '5,11p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-1}"; }
[[ "${1:-}" == (-h|--help) ]] && usage 0
(( $# )) || usage
APP_NAME="$1"; shift
DIR="" BUNDLE_ID="" SLUG=""
while (( $# )); do
    case "$1" in
        --dir) DIR="$2"; shift 2 ;;
        --bundle-id) BUNDLE_ID="$2"; shift 2 ;;
        --slug) SLUG="$2"; shift 2 ;;
        *) usage ;;
    esac
done

[[ "$APP_NAME" =~ '^[A-Za-z][A-Za-z0-9 ]*$' ]] || { echo "The name may contain letters, digits and spaces (and starts with a letter)." >&2; exit 1; }
EXECUTABLE="${APP_NAME// /}"
LOWER="${(L)EXECUTABLE}"
SLUG="${SLUG:-${(L)APP_NAME// /-}}"
BUNDLE_ID="${BUNDLE_ID:-io.github.furcenzo.$LOWER}"
DEFAULT_DIR="$KIT/../$APP_NAME"
DIR="${${DIR:-$DEFAULT_DIR}:A}"
[[ ! -e "$DIR" ]] || { echo "$DIR already exists." >&2; exit 1; }

export APP_NAME EXECUTABLE BUNDLE_ID SLUG
export CORE="${EXECUTABLE}Core" REPO="Furcenzo/$SLUG" INITIAL="${(U)APP_NAME[1]}"

cp -R "$KIT/template" "$DIR"
cp "$KIT/LICENSE" "$DIR/LICENSE"
cd "$DIR"
# Folder and file names with placeholders (deepest first), then the placeholders in the files.
for item in ${(On)${(f)"$(find . -name '*__*__*')"}}; do
    new="${item:h}/${${${item:t}//__EXECUTABLE__/$EXECUTABLE}//__CORE__/$CORE}"
    mv "$item" "$new"
done
find . -type f -print0 | xargs -0 perl -pi -e '
    s/__APP_NAME__/$ENV{APP_NAME}/g; s/__EXECUTABLE__/$ENV{EXECUTABLE}/g; s/__CORE__/$ENV{CORE}/g;
    s/__BUNDLE_ID__/$ENV{BUNDLE_ID}/g; s/__SLUG__/$ENV{SLUG}/g; s/__REPO__/$ENV{REPO}/g;
    s/__INITIAL__/$ENV{INITIAL}/g'
! grep -rn '__[A-Z_]*__' . || { echo "Unreplaced placeholders above." >&2; exit 1; }

"$KIT/sync.sh" "$DIR" >/dev/null
./scripts/make-icon.sh

git init --quiet -b main
git config user.name Furcenzo
git config user.email 60021487+Furcenzo@users.noreply.github.com
git config core.hooksPath .githooks
git add -A
git commit --quiet -m "New app $APP_NAME from mac-app-kit"

if [[ "$DIR" == "${DEFAULT_DIR:A}" ]]; then
    print -r -- "../$APP_NAME" >> "$KIT/apps.txt"
    echo "Added ../$APP_NAME to apps.txt."
fi
echo
echo "Created $DIR ($BUNDLE_ID)."
echo "Next: cd \"$DIR\" && ./scripts/run.sh   (once per Mac: ./scripts/setup-dev-signing.sh)"
echo "Before the first release: create github.com/$REPO and the cask Casks/$SLUG.rb in Furcenzo/homebrew-tap."
