#!/usr/bin/env bash
# GridCraft -> Malu123 rename. The single source of the name mapping (docs/malu123/rename.md).
#
# Run from the repository root on a clean tree. Idempotent. Does, in order:
#   1. removes upstream's ArtCraft brand files (their licence requires it of forks)
#   2. git-moves every tracked path whose name contains "gridcraft" (app id first)
#   3. rewrites the text of every tracked file with scripts/rename-upstream.py
#   4. cargo fmt (shorter identifiers let rustfmt rejoin lines)
#
# Upstream sync (vendor branch): on `upstream-renamed`, `git merge upstream/main`, resolve any
# conflicts by re-running this script, commit, then `git merge upstream-renamed` on main.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# Files this script never rewrites: they describe the fork itself.
SKIP='^(README\.md|NOTICE|LICENSE-MIT|LICENSE-APACHE|docs/malu123/.*|scripts/rename-upstream\..*)$'

# 1. brand files
if [ -d docs/brand ]; then git rm -rq docs/brand; fi

# 2. paths
{ git ls-files | grep -i gridcraft || true; } | sort -r | while read -r old; do
  new=$(printf '%s' "$old" | sed -e 's/ai\.storyteller\.gridcraft/org.maluos.malu123/g' -e 's/gridcraft/malu123/g')
  [ "$old" = "$new" ] && continue
  mkdir -p "$(dirname "$new")"
  git mv -k "$old" "$new"
done
find apps crates packaging assets -type d -empty -delete 2>/dev/null || true

# 3. text
git ls-files | grep -Ev "$SKIP" | xargs -d '\n' python3 scripts/rename-upstream.py

# 4. fmt
if command -v cargo >/dev/null; then cargo fmt --all; fi

left=$(git ls-files | grep -Ev "$SKIP" | xargs -d '\n' grep -Il -i gridcraft 2>/dev/null | wc -l)
echo "rename-upstream.sh: done; $left file(s) still mention gridcraft (expected: upstream credits only)"
