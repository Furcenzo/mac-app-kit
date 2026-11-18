#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Furcenzo
#
# Copies the shared files (everything under files/) into the apps, or checks that they still match.
#   ./sync.sh                     copy into every app listed in apps.txt
#   ./sync.sh ../Lineup           copy into the given app folder(s)
#   ./sync.sh --check [folder…]   only compare; lists files that differ or are missing, exit code 1 if any
#   ./sync.sh --diff [folder…]    like --check, and shows the differences (kit → app)
# The apps keep their own copies (each public repository builds without the kit); the app's settings are in
# its app.conf, which this script never touches. Commit the copied files in the app afterwards.
set -euo pipefail
KIT="${0:A:h}"

MODE=copy
case "${1:-}" in
    --check) MODE=check; shift ;;
    --diff) MODE=diff; shift ;;
    -h|--help) sed -n '5,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
esac

APPS=("$@")
if (( ! ${#APPS} )); then
    # apps.txt: one folder per line, relative to the kit; # starts a comment.
    APPS=("${(@f)$(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$KIT/apps.txt")}")
    APPS=("${APPS[@]/#/$KIT/}")
fi

# Same content and the same executable bit.
same() {
    cmp -s "$1" "$2" || return 1
    if [[ -x "$1" ]]; then [[ -x "$2" ]]; else [[ ! -x "$2" ]]; fi
}

FILES=("${(@f)$(cd "$KIT/files" && find . -type f ! -name .DS_Store | sed 's|^\./||' | sort)}")
rc=0
for app in "${APPS[@]}"; do
    app="${app:A}"
    if [[ ! -f "$app/app.conf" ]]; then
        echo "$app: no app.conf – not a mac-app-kit app (new apps: ./new-app.sh)" >&2
        rc=1
        continue
    fi
    differ=()
    for f in "${FILES[@]}"; do
        src="$KIT/files/$f" dst="$app/$f"
        if [[ "$MODE" == copy ]]; then
            if ! same "$src" "$dst"; then
                mkdir -p "${dst:h}"
                cp -p "$src" "$dst"
                differ+=("$f")
            fi
        elif [[ ! -f "$dst" ]]; then
            differ+=("$f (missing)")
        elif ! same "$src" "$dst"; then
            differ+=("$f")
            [[ "$MODE" == diff ]] && { diff -u "$dst" "$src" --label "app/$f" --label "kit/$f" || true; }
        fi
    done
    if [[ "$MODE" == copy ]]; then
        if (( ${#differ} )); then
            echo "${app:t}: updated ${#differ} file(s):"
            printf '  %s\n' "${differ[@]}"
        else
            echo "${app:t}: already up to date"
        fi
    elif (( ${#differ} )); then
        echo "${app:t}: ${#differ} file(s) differ from the kit:"
        printf '  %s\n' "${differ[@]}"
        rc=1
    else
        echo "${app:t}: matches the kit (${#FILES} files)"
    fi
done
exit $rc
